import 'package:flutter_test/flutter_test.dart';
import 'package:hostel_finder_app/core/enums/availability_status.dart';
import 'package:hostel_finder_app/core/enums/listing_status.dart';
import 'package:hostel_finder_app/core/enums/verification_status.dart';
import 'package:hostel_finder_app/data/models/hostel_model.dart';
import 'package:hostel_finder_app/features/owner/shell/owner_add_access.dart';

HostelModel _h(String id, ListingStatus s) => HostelModel(
      id: id,
      ownerId: 'o',
      ownerName: 'n',
      name: 'n',
      fullAddress: 'a',
      city: 'c',
      latitude: 0,
      longitude: 0,
      description: '',
      pricePerMonth: 1,
      photos: const [],
      amenities: const {},
      availability: AvailabilityStatus.available,
      contactPhone: '',
      contactWhatsapp: '',
      status: s,
    );

List<HostelModel> _pending(int n) =>
    [for (var i = 0; i < n; i++) _h('p$i', ListingStatus.pending)];

OwnerAddAccess _access(
  VerificationStatus user,
  String? doc,
  List<HostelModel> hostels,
) =>
    resolveOwnerAddAccess(
      userStatus: user,
      verificationDocStatus: doc,
      hostels: hostels,
    );

void main() {
  const unverified = VerificationStatus.unverified;

  test('the cap is 3', () => expect(kMaxPendingHostels, 3));

  test('verified owner is always allowed, even with many pending', () {
    expect(_access(VerificationStatus.verified, 'approved', _pending(5)),
        OwnerAddAccess.allowed);
  });

  test('no verification submitted yet needs verification', () {
    expect(_access(unverified, null, []), OwnerAddAccess.needsVerification);
    expect(_access(unverified, 'draft', []), OwnerAddAccess.needsVerification);
  });

  test('submitted identity allows 0, 1 and 2 hostels in review', () {
    for (final n in [0, 1, 2]) {
      expect(_access(unverified, 'pending', _pending(n)), OwnerAddAccess.allowed,
          reason: '$n pending');
    }
  });

  test('3 pending hostels reaches the limit', () {
    expect(_access(unverified, 'pending', _pending(3)),
        OwnerAddAccess.limitReached);
    expect(_access(unverified, 'changesRequested', _pending(3)),
        OwnerAddAccess.limitReached);
  });

  test('drafts, rejected and published hostels do not count', () {
    final hostels = [
      ..._pending(2),
      for (var i = 0; i < 5; i++) _h('d$i', ListingStatus.draft),
      _h('r', ListingStatus.rejected),
    ];
    expect(_access(unverified, 'pending', hostels), OwnerAddAccess.allowed);
  });

  test('a rejected owner must resubmit verification', () {
    expect(_access(VerificationStatus.rejected, 'rejected', []),
        OwnerAddAccess.rejected);
    expect(_access(unverified, 'rejected', []), OwnerAddAccess.rejected);
  });
}
