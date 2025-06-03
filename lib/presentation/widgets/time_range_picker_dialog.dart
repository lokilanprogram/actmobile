import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:acti_mobile/configs/colors.dart'; // Assuming mainBlueColor and authBlueColor are defined here

class TimeRangePickerDialog extends StatefulWidget {
  final String? initialStartTime;
  final String? initialEndTime;

  const TimeRangePickerDialog({
    super.key,
    this.initialStartTime,
    this.initialEndTime,
  });

  @override
  _TimeRangePickerDialogState createState() => _TimeRangePickerDialogState();
}

class _TimeRangePickerDialogState extends State<TimeRangePickerDialog> {
  String? _selectedStartTime;
  String? _selectedEndTime;
  List<String> timeSlots = [];

  @override
  void initState() {
    super.initState();
    _selectedStartTime = widget.initialStartTime;
    _selectedEndTime = widget.initialEndTime;
    _generateTimeSlots();
  }

  void _generateTimeSlots() {
    for (int hour = 0; hour <= 24; hour++) {
      final time = '${hour.toString().padLeft(2, '0')}:00';
      timeSlots.add(time);
    }
  }

  // Logic to handle tapping on a time slot
  void _onTimeSlotTapped(String time) {
    setState(() {
      if (_selectedStartTime == null) {
        // Select start time
        _selectedStartTime = time;
      } else if (_selectedEndTime == null) {
        // Select end time
        _selectedEndTime = time;
        // Ensure start is before end
        if (DateFormat('HH:mm')
            .parse(_selectedStartTime!)
            .isAfter(DateFormat('HH:mm').parse(_selectedEndTime!))) {
          final temp = _selectedStartTime;
          _selectedStartTime = _selectedEndTime;
          _selectedEndTime = temp;
        }
      } else {
        // Clear current range and start new selection
        _selectedStartTime = time;
        _selectedEndTime = null;
      }
    });
  }

  // Helper to check if a time slot is within the selected range
  bool _isInSelectedRange(String time) {
    if (_selectedStartTime == null || _selectedEndTime == null) {
      return false;
    }
    final timeDateTime = DateFormat('HH:mm').parse(time);
    final startDateTime = DateFormat('HH:mm').parse(_selectedStartTime!);
    final endDateTime = DateFormat('HH:mm').parse(_selectedEndTime!);

    // Check if time is exactly the start or end time
    if (timeDateTime.isAtSameMomentAs(startDateTime) ||
        timeDateTime.isAtSameMomentAs(endDateTime)) {
      return true;
    }

    // Check if time is strictly between start and end time
    return timeDateTime.isAfter(startDateTime) &&
        timeDateTime.isBefore(endDateTime);
  }

  // Helper to check if a time slot is the start time
  bool _isStartTime(String time) {
    if (_selectedStartTime == null) return false;
    return time == _selectedStartTime;
  }

  // Helper to check if a time slot is the end time
  bool _isEndTime(String time) {
    if (_selectedEndTime == null) return false;
    return time == _selectedEndTime;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text(
              'Время',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16.0),
          SingleChildScrollView(
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: timeSlots.map((time) {
                bool isSelected = _isInSelectedRange(time);
                bool isStart = _isStartTime(time);
                bool isEnd = _isEndTime(time);

                Color backgroundColor = Colors.grey[200]!;
                Color textColor = Colors.black;
                if (isStart || isEnd) {
                  backgroundColor = mainBlueColor;
                  textColor = Colors.white;
                } else if (isSelected) {
                  backgroundColor = mainBlueColor.withOpacity(0.2);
                  textColor = Colors.black;
                }

                return SizedBox(
                  width: (MediaQuery.of(context).size.width - 80) / 4,
                  child: GestureDetector(
                    onTap: () => _onTimeSlotTapped(time),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 100),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      alignment: Alignment.center,
                      child: Text(
                        time,
                        style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                            color: textColor),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 16.0),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, [_selectedStartTime, _selectedEndTime]);
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                backgroundColor: authBlueColor,
                foregroundColor: Colors.white,
              ),
              child: Text('Сохранить', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
