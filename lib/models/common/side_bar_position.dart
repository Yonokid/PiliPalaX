enum SideBarPosition {
  none,
  leftFixed,
  rightFixed,
  leftHorizontal,
  rightHorizontal
}

extension SideBarPositionDesc on SideBarPosition {
  String get values => [
        'none',
        'left_fixed',
        'right_fixed',
        'left_horizontal',
        'right_horizontal'
      ][index];
  String get labels => ['None', 'Left (Fixed)', 'Right (Fixed)', 'Left (Horizontal)', 'Right (Horizontal)'][index];
}

extension SideBarPositionCode on SideBarPosition {
  int get code => index;
  static SideBarPosition? fromCode(int code) {
    if (code >= 0 && code < SideBarPosition.values.length) {
      return SideBarPosition.values[code];
    }
    return null;
  }
}
