import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import '../models/hostel_model.dart';
import '../../core/enums/listing_status.dart';
import '../../core/utils/logger.dart';

// Pagination/infinite scroll (TASK-Phase-7.md Block G) — explicitly
// DEFERRED, not silently skipped. Every list screen (Home, Search, Saved,
// Owner Listings) is a SingleChildScrollView over a plain Column with no
// ScrollController anywhere (finding #11) — adding real windowing would be
// a view-level change on every one of those screens, not just a repository
// change, for a catalog size this app doesn't have yet. streamFeatured/
// streamAllPublished/streamByOwner below intentionally return the full
// matching set; revisit with startAfter/limit cursors once the real
// listing count justifies not holding it all in memory.
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

  Stream<List<HostelModel>> streamFeatured() {
    return _hostelsRef
        .where('status', isEqualTo: ListingStatus.published.name)
        .where('isFeatured', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<HostelModel>> streamAllPublished() {
    return _hostelsRef
        .where('status', isEqualTo: ListingStatus.published.name)
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

  Stream<List<HostelModel>> streamByOwner(String ownerId) {
    return _hostelsRef
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
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
      await _hostelsRef.doc(hostel.id).set(hostel, SetOptions(merge: true));
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
