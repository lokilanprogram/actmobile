import 'package:acti_mobile/presentation/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CreateEventScreen extends StatefulWidget {
  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  bool isOnline = false;
  bool isRecurring = false;
  bool is18plus = false;
  bool isPetFriendly = false;
  bool isUnlimited = false;
  bool isGroupChat = false;
  int peopleCount = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: AppBarWidget(title: "Создание активности"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildImagePicker(),
            const SizedBox(height: 16),

            _buildTextField("Название события"),
            _buildSwitchTile("Событие ОНЛАЙН", isOnline, (v) => setState(() => isOnline = v)),
            _buildTextField("Адрес"),
            _buildSwitchTile("Повторяющееся событие", isRecurring, (v) => setState(() => isRecurring = v)),
            
            _buildDatePickerField("Дата"),
            const SizedBox(height: 8),
            _buildTimePicker("Время начала"),
            _buildTimePicker("Время завершения"),

            _buildTextField("Стоимость участия", suffixText: "₽"),
            _buildSwitchTile("Ограничение 18+", is18plus, (v) => setState(() => is18plus = v)),
            _buildSwitchTile("Можно с животными", isPetFriendly, (v) => setState(() => isPetFriendly = v)),
            _buildSwitchTile("Количество человек неограниченно", isUnlimited, (v) => setState(() => isUnlimited = v)),

            const SizedBox(height: 12),
            _buildPeopleCounter(),

            _buildSwitchTile("Создать групповой чат", isGroupChat, (v) => setState(() => isGroupChat = v)),
            _buildTextField("Описание", maxLines: 4),
            
            const SizedBox(height: 16),
            _buildCategoryChips(),

            const SizedBox(height: 24),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
            onTap: () {},
            child: SvgPicture.asset('assets/icons/icon_add_photo.svg')
          ); 
  }

  Widget _buildTextField(String label, {int maxLines = 1, String? suffixText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffixText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildDatePickerField(String label) {
    return _buildTextField(label); // можно заменить на DatePicker
  }

  Widget _buildTimePicker(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("18"),
              Text(":"),
              Text("00"),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildPeopleCounter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(onPressed: () => setState(() => peopleCount--), icon: const Icon(Icons.arrow_left)),
        Text('$peopleCount', style: const TextStyle(fontSize: 20)),
        IconButton(onPressed: () => setState(() => peopleCount++), icon: const Icon(Icons.arrow_right)),
      ],
    );
  }

  Widget _buildCategoryChips() {
    final categories = [
      "Выставки и торги", "Музыка", "Игры",
      "Гимнастика", "Еда", "Технологии"
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories
          .map((cat) => ChoiceChip(
                label: Text(cat),
                selected: false,
                onSelected: (_) {},
              ))
          .toList(),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: const Text("Сохранить", style: TextStyle(fontSize: 18)),
    );
  }
}
