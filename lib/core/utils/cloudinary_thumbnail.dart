/// Derives a Cloudinary transformation URL from a stored full-size
/// `secure_url`, for card/thumbnail rendering (Phase 7 Block A.8).
///
/// Recommended approach per TASK-Phase-7.md A.8: derive the thumbnail URL
/// at render time from the stored full URL, rather than storing two URLs
/// per photo — Cloudinary transformation URLs are deterministic string
/// manipulation on the `.../upload/<transform>/...` segment.
class CloudinaryThumbnail {
  CloudinaryThumbnail._();

  /// 400px-wide, cropped-to-fill, auto-format, auto-quality — sized for
  /// `HostelCard`/`OwnerListingCard` list rendering, not full-screen
  /// detail-gallery viewing.
  static const String _cardTransform = 'w_400,c_fill,f_auto,q_auto';

  /// Returns the thumbnail-transformed URL, or [url] unchanged if it isn't
  /// a Cloudinary delivery URL (e.g. a bundled asset path, or a local
  /// file path for a photo still mid-upload) — always safe to call.
  static String of(String url) {
    const marker = '/upload/';
    final idx = url.indexOf(marker);
    if (idx == -1) return url;
    final insertAt = idx + marker.length;
    // Already has a transformation segment (defensive — nothing in this
    // app writes one today) — don't double up.
    if (url.startsWith(_cardTransform, insertAt)) return url;
    return '${url.substring(0, insertAt)}$_cardTransform/${url.substring(insertAt)}';
  }
}
