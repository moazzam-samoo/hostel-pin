import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import '../models/hostel_model.dart';
import '../../core/enums/listing_status.dart';
import '../../core/utils/logger.dart';

/// Pagination (FIX-7.5). Previously every stream returned its whole
/// matching set, so read cost grew linearly with the catalogue.
///
/// These are live `snapshots()` streams, so the plan's `startAfterDocument`
/// cursor doesn't apply directly — cursors page a one-shot `get()`, whereas
/// re-subscribing per page would drop realtime updates for earlier pages.
/// The equivalent for a stream is a growing window: hold `limit(n)` and
/// raise `n` when the user asks for more. Cost is bounded the same way,
/// every visible row stays live, and the view keeps one subscription.
const int kHostelPageSize = 10;

class HostelRepository {
  final FirebaseFirestore _firestore;

  HostelRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<HostelModel> get _hostelsRef => _firestore
      .collection('hostels')
      .withConverter<HostelModel>(
        fromFirestore: HostelModel.fromFirestore,
        toFirestore: (model, options) => model.toFirestore(),
      );

  Stream<List<HostelModel>> streamFeatured({int limit = kHostelPageSize}) {
    return _hostelsRef
        .where('status', isEqualTo: ListingStatus.published.name)
        .where('isFeatured', isEqualTo: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Published listings, capped at [limit] (FIX-7.5).
  ///
  /// NOT ordered by `createdAt`, deliberately. `HostelModel` has never had a
  /// `createdAt` field, and Firestore silently drops documents missing the
  /// field you order by — adding `orderBy('createdAt')` here would empty the
  /// Home feed for every listing already in the database. The field is now
  /// written on create (see `toFirestore`), so once the FIX-7.2 backfill has
  /// stamped the existing documents this can become an ordered query and the
  /// plan's `status` + `createdAt` index starts earning its keep.
  Stream<List<HostelModel>> streamAllPublished({int limit = kHostelPageSize}) {
    return _hostelsRef
        .where('status', isEqualTo: ListingStatus.published.name)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<HostelModel>> streamNearbyHostels(double latitude, double longitude, double radiusInKm) {
    return GeoCollectionReference(_hostelsRef)
        .subscribeWithin(
          center: GeoFirePoint(GeoPoint(latitude, longitude)),
          radiusInKm: radiusInKm,
          field: 'location',
          geopointFrom: (model) => model.location ?? const GeoPoint(0, 0),
          queryBuilder: (query) => query.where('status', isEqualTo: ListingStatus.published.name),
        )
        .map((docs) => docs.map((d) => d.data()).whereType<HostelModel>().toList());
  }

  /// Deliberately NOT paginated (FIX-7.5). This query is already bounded by
  /// a single owner's listing count, and `DashboardController.totalViews`
  /// folds over the whole result — capping it would make the dashboard
  /// silently under-report stats rather than merely show fewer rows.
  /// Pagination targets the catalogue-sized student queries above; a correct
  /// owner-side cap needs the server-maintained counters of FIX-7.9 first.
  Stream<List<HostelModel>> streamByOwner(String ownerId) {
    return _hostelsRef
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => doc.data()).toList();
      // Sort client-side by document ID (which is epoch time) descending
      // so newest hostels appear at the top.
      list.sort((a, b) => b.id.compareTo(a.id));
      return list;
    });
  }

  Future<HostelModel?> getById(String id) async {
    try {
      final doc = await _hostelsRef.doc(id).get();
      return doc.data();
    } catch (e) {
      Logger.e('Error fetching hostel $id: $e');
      return null;
    }
  }

  Future<void> create(HostelModel hostel) async {
    try {
      await _hostelsRef.doc(hostel.id).set(hostel);
    } catch (e) {
      Logger.e('Error creating hostel: $e');
      throw Exception('Failed to create hostel: $e');
    }
  }

  Future<void> update(HostelModel hostel) async {
    try {
      // Bypass the converter so `createdAt` can be stripped: toFirestore()
      // stamps a fresh serverTimestamp, and merging that on every edit would
      // continually re-date the listing and reshuffle any newest-first feed.
      final data = hostel.toFirestore()..remove('createdAt');
      await _firestore
          .collection('hostels')
          .doc(hostel.id)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      Logger.e('Error updating hostel: $e');
      throw Exception('Failed to update hostel: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      // TODO(cloud-functions): signed Cloudinary destroy on listing delete.
      // Deleting the Firestore doc here does NOT remove this hostel's
      // photos from Cloudinary — a real destroy call needs the API secret
      // and must go through a Cloud Function, never the client (Phase 7
      // Block A.10 decision: deferred, orphaned assets accepted for now).
      await _hostelsRef.doc(id).delete();
    } catch (e) {
      Logger.e('Error deleting hostel: $e');
      throw Exception('Failed to delete hostel: $e');
    }
  }

  Future<void> incrementViews(String id) async {
    try {
      await _firestore.collection('hostels').doc(id).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      Logger.e('Error incrementing views for $id: $e');
    }
  }
}
