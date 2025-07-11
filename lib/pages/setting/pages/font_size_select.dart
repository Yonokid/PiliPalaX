import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/utils/storage.dart';

class FontSizeSelectPage extends StatefulWidget {
  const FontSizeSelectPage({super.key});

  @override
  State<FontSizeSelectPage> createState() => _FontSizeSelectPageState();
}

class _FontSizeSelectPageState extends State<FontSizeSelectPage> {
  Box setting = GStorage.setting;
  List<double> list = List.generate(12, (index) => 0.85 + index * 0.05);
  //[0.85, 0.9, 0.95, 1.0, 1.05, 1.1, 1.15, 1.2, 1.25, 1.3, 1.35];
  late double minSize;
  late double maxSize;
  late double currentSize;

  @override
  void initState() {
    super.initState();
    minSize = list.first;
    maxSize = list.last;
    currentSize =
        setting.get(SettingBoxKey.defaultTextScale, defaultValue: 1.0);
  }

  setFontSize() {
    setting.put(SettingBoxKey.defaultTextScale, currentSize);
    Get.forceAppUpdate();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(onPressed: () => setFontSize(), child: const Text('确定')),
          const SizedBox(width: 12)
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Current Font Size: ${currentSize == 1.0 ? 'Default' : currentSize}',
                style: TextStyle(fontSize: 14 * currentSize),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).padding.bottom + 20,
            ),
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.3))),
              color: Theme.of(context).colorScheme.background,
            ),
            child: Row(
              children: [
                const Text('Small'),
                Expanded(
                  child: Slider(
                    min: minSize,
                    value: currentSize,
                    max: maxSize,
                    divisions: list.length - 1,
                    secondaryTrackValue: 1,
                    onChanged: (double val) {
                      currentSize = double.parse(val.toStringAsFixed(2));
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'Large',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
