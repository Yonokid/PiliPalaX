enum UpPanelPosition {
  leftFixed,
  rightFixed,
  leftDrawer,
  rightDrawer,
}

extension UpPanelPositionDesc on UpPanelPosition {
  String get values => ['left_fixed', 'right_fixed', 'left_drawer', 'right_drawer'][index];
  String get labels => ['Left (Fixed)','Right (Fixed)','Left (Drawer)','Right (Drawer)'][index];
}

extension UpPanelPositionCode on UpPanelPosition {
  int get code => [0, 1, 2, 3][index];
}
