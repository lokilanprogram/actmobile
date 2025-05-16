import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PhotoPickerWidget extends StatefulWidget {
  @override
  State<PhotoPickerWidget> createState() => _PhotoPickerWidgetState();
}

class _PhotoPickerWidgetState extends State<PhotoPickerWidget> {
  final List<XFile> _images = [];
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _images.add(picked);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Widget _buildImage(XFile image, int index, double width,double height) {
    return Padding(
      padding: const EdgeInsets.only(left: 3),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(image.path),
              width: width,
              height: height,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallAddButton() {
    return Expanded(
      child: GestureDetector(
        onTap: _pickImage,
        child: SvgPicture.asset(
          'assets/icons/icon_add_photo_small.svg',
       
        ),
      ),
    );
  }

  Widget _buildLargeAddButton() {
    return GestureDetector(
      onTap: _pickImage,
      child: SvgPicture.asset(
        'assets/icons/icon_add_photo_activity.svg',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> bottomGrid = [];
    if (_images.length > 1) {
      for (int i = 1; i < _images.length; i++) {
        bottomGrid.add(_buildImage(_images[i], i, 80, 80));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_images.isEmpty) ...[
          _buildLargeAddButton(),
        ] else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(_images[0], 0,MediaQuery.of(context).size.height * 0.24, 150),
              const SizedBox(width: 8),
              _buildSmallAddButton(),
            ],
          ),
        ],
        const SizedBox(height: 16),
        if (bottomGrid.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: bottomGrid,
          ),
        const SizedBox(height: 16),
       
      ],
    );
  }
}
