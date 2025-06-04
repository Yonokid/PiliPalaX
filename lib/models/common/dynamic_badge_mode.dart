enum DynamicBadgeMode { hidden, point, number }

extension DynamicBadgeModeDesc on DynamicBadgeMode {
  String get description => ['Hide', 'Red Dot', 'Number'][index];
}

extension DynamicBadgeModeCode on DynamicBadgeMode {
  int get code => [0, 1, 2][index];
}
