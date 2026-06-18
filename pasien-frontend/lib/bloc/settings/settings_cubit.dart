import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsCubit extends Cubit<double> {
  static const String _fontScaleKey = 'font_scale_key';
  
  // Default font scale is 1.3 (Besar) to accommodate elderly users
  SettingsCubit() : super(1.3) {
    _loadFontScale();
  }

  Future<void> _loadFontScale() async {
    final prefs = await SharedPreferences.getInstance();
    final double? savedScale = prefs.getDouble(_fontScaleKey);
    if (savedScale != null) {
      emit(savedScale);
    } else {
      // If not set, emit the default and save it
      emit(1.3);
      await prefs.setDouble(_fontScaleKey, 1.3);
    }
  }

  Future<void> changeFontScale(double scale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontScaleKey, scale);
    emit(scale);
  }
}
