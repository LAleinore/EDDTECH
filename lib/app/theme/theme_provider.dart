import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/auth_repository.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ThemeNotifier(storage.isDarkTheme(), storage.setDarkTheme);
});

class ThemeNotifier extends StateNotifier<bool> {
  final Future<void> Function(bool) _save;

  ThemeNotifier(super.initial, this._save);

  Future<void> toggleDarkTheme(bool isDark) async {
    state = isDark;
    await _save(isDark);
  }
}
