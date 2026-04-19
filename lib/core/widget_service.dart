import 'package:home_widget/home_widget.dart';

class WidgetService {
  const WidgetService();

  Future<void> saveWidgetData(String name) async {
    try {
      await HomeWidget.saveWidgetData<String>('last_scanned_medicine', name);
      await HomeWidget.updateWidget(androidName: 'SmartPrescriptionHomeWidget');
      print('Saved widget medicine: $name');
    } catch (error) {
      print('Widget save failed: $error');
    }
  }

  Future<void> updateHomeWidget(String pharmacyName) async {
    await saveWidgetData(pharmacyName);
  }
}
