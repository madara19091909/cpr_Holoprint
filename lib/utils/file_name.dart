String sanitizeDownloadName(String input) {
  var name = input.trim().replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '_');
  name = name.replaceAll(RegExp(r'\s+'), ' ');
  if (name.isEmpty) name = 'CPR-Holoprint.mcpack';
  if (!name.toLowerCase().endsWith('.mcpack') &&
      !name.toLowerCase().endsWith('.mcaddon')) {
    name = '$name.mcpack';
  }
  return name;
}
