import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OrgToggleTooltip extends StatefulWidget {
  const OrgToggleTooltip({super.key});

  @override
  State<OrgToggleTooltip> createState() => _OrgToggleTooltipState();
}

class _OrgToggleTooltipState extends State<OrgToggleTooltip> {
  OverlayEntry? _overlayEntry;

  void _toggleTooltip() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy +size.height + 8,
        left: offset.dx + size.width / 2 - 140 / 2, // Центр под иконкой
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 140,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F0FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Эта информация будет видна другим',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Gilroy',
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleTooltip,
      child: SvgPicture.asset(
        'assets/icons/icon_info.svg',
        width: 20,
        height: 20,
        fit: BoxFit.cover,
      ),
    );
  }
}
