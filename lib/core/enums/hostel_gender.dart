import '../constants/app_strings.dart';

/// Who a hostel is for. Stored on `hostels/{id}.gender` as `boys` | `girls`.
/// Hostels created before this field existed have none (null) and appear only
/// under the Home screen's "All" category.
enum HostelGender {
  boys,
  girls;

  String get label => this == HostelGender.boys
      ? AppStrings.hostelGenderBoys
      : AppStrings.hostelGenderGirls;

  static HostelGender? tryParse(Object? value) {
    for (final g in HostelGender.values) {
      if (g.name == value) return g;
    }
    return null;
  }
}
