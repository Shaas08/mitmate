import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Answers collected across onboarding screens before the profile is saved.
class Onboarding {
  const Onboarding({this.city = 'berlin'});
  final String city;
  Onboarding copyWith({String? city}) => Onboarding(city: city ?? this.city);
}

final onboardingProvider = StateProvider<Onboarding>((ref) => const Onboarding());
