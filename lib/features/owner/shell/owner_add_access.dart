import '../../../core/enums/listing_status.dart';
import '../../../core/enums/verification_status.dart';
import '../../../data/models/hostel_model.dart';

/// Most hostels an owner may have in review at once while still unverified.
/// Enforced in the app only (Firestore rules cannot count documents).
const int kMaxPendingHostels = 3;

/// What the Add tab (and publishing) may do for the signed-in owner.
enum OwnerAddAccess { allowed, needsVerification, limitReached, rejected }

/// Decides whether an owner can add another hostel right now.
///
/// [verificationDocStatus] is `verifications/{uid}.status` (null when the owner
/// never started). The user's own `verificationStatus` is only flipped by the
/// admin, so the submitted-for-review signal comes from the verification doc.
OwnerAddAccess resolveOwnerAddAccess({
  required VerificationStatus userStatus,
  required String? verificationDocStatus,
  required List<HostelModel> hostels,
}) {
  if (userStatus == VerificationStatus.verified) return OwnerAddAccess.allowed;
  if (userStatus == VerificationStatus.rejected ||
      verificationDocStatus == 'rejected') {
    return OwnerAddAccess.rejected;
  }
  final submitted = verificationDocStatus == 'pending' ||
      verificationDocStatus == 'changesRequested';
  if (!submitted) return OwnerAddAccess.needsVerification;
  final inReview = hostels.where((h) => h.status == ListingStatus.pending).length;
  return inReview >= kMaxPendingHostels
      ? OwnerAddAccess.limitReached
      : OwnerAddAccess.allowed;
}
