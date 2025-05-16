import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoTimePicker extends StatefulWidget {
  const CupertinoTimePicker({Key? key}) : super(key: key);

  @override
  State<CupertinoTimePicker> createState() => _CupertinoTimePickerState();
}

class _CupertinoTimePickerState extends State<CupertinoTimePicker> {
  int selectedHour = 18;
  int selectedMinute = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Время начала:'),
          SizedBox(height: 8),
          Container(
            height: 150, // Adjust the height as needed
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoPicker(
                  itemExtent: 32,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      selectedHour = index;
                    });
                  },
                  children: List<Widget>.generate(24, (index) {
                    return Center(
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: TextStyle(fontSize: 24),
                      ),
                    );
                  }),
                ),
                Text(':', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                CupertinoPicker(
                  itemExtent: 32,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      selectedMinute = index;
                    });
                  },
                  children: List<Widget>.generate(60, (index) {
                    return Center(
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: TextStyle(fontSize: 24),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Text('Выбранное время: ${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}'),
        ],
      ),
    );
  }
}