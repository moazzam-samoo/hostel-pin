import 'package:flutter/material.dart';

enum Amenity {
  wifi(
    title: 'Fast Wifi',
    subtitle: 'Gigabit Speed',
    icon: Icons.wifi,
  ),
  meals(
    title: '3 Meals',
    subtitle: 'Tasty food',
    icon: Icons.restaurant,
  ),
  security(
    title: 'Security',
    subtitle: 'Camera 24/7',
    icon: Icons.security,
  ),
  laundry(
    title: 'Laundry',
    subtitle: 'Self-service',
    icon: Icons.local_laundry_service,
  ),
  parking(
    title: 'Parking',
    subtitle: 'Car+Bike',
    icon: Icons.local_parking,
  ),
  beds(
    title: 'Beds',
    subtitle: 'Separate',
    icon: Icons.bed,
  ),
  gym(
    title: 'Gym',
    subtitle:
        'Free gym access', // Gym subtitle doesn't exist in mockups, adding a default one
    icon: Icons.fitness_center,
  ),
  solar(
    title: 'Solar Power',
    subtitle: 'Uninterruptible',
    icon: Icons.wb_sunny,
  ),
  locker(
    title: 'Locker',
    subtitle: 'Secure storage',
    icon: Icons.lock,
  ),
  water(
    title: 'Filtered Water',
    subtitle: '24/7 Supply',
    icon: Icons.water_drop,
  ),
  acRooms(
    title: 'AC Rooms',
    subtitle: 'Air conditioned',
    icon: Icons.ac_unit,
  );

  final String title;
  final String subtitle;
  final IconData icon;

  const Amenity({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
