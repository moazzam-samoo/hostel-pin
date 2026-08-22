import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:map_launcher/map_launcher.dart';
import '../constants/app_strings.dart';
import '../../shared/widgets/feedback/app_snackbar.dart';

Future<void> openDirectionsTo({
  required double latitude,
  required double longitude,
  String? title,
}) async {
  try {
    final destination = Location.coords(latitude, longitude, title: title);
    final request = MapLauncher.directions(destination);

    final availableMaps = await request.getSupportedMaps([
      MapApp.google,
      MapApp.apple,
      MapApp.waze,
    ]);

    if (availableMaps.isEmpty) {
      AppSnackbar.showGlobal(
        message: AppStrings.noMapsAppFound,
        type: SnackbarType.error,
      );
      return;
    }

    if (availableMaps.length == 1) {
      await request.show(map: availableMaps.first.map);
      return;
    }

    if (Get.context != null) {
      showModalBottomSheet(
        context: Get.context!,
        builder: (BuildContext context) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Wrap(
                children: <Widget>[
                  for (var supportedMap in availableMaps)
                    ListTile(
                      onTap: () {
                        request.show(map: supportedMap.map);
                        Navigator.pop(context);
                      },
                      title: Text(supportedMap.map.name),
                    ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      await request.show(map: availableMaps.first.map);
    }
  } catch (e) {
    AppSnackbar.showGlobal(
      message: AppStrings.noMapsAppFound,
      type: SnackbarType.error,
    );
  }
}
