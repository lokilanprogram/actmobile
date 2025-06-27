import 'package:acti_mobile/configs/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

class ToggleMessage extends StatefulWidget {
  final String message;
  final ScrollController scrollController;
  final Widget child;
  final Function deleteMessage;

  const ToggleMessage(
      {super.key,
      required this.scrollController,
      required this.child,
      required this.message,
      required this.deleteMessage});

  @override
  State<ToggleMessage> createState() => _ToggleMessageState();
}

class _ToggleMessageState extends State<ToggleMessage> {
  static OverlayEntry? _currentOverlayEntry;
  static void _removeCurrentOverlay() {
    _currentOverlayEntry?.remove();
    _currentOverlayEntry = null;
  }

  void _toggleTooltip() {
    if (_currentOverlayEntry == null) {
      _currentOverlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_currentOverlayEntry!);
    } else {
      _removeCurrentOverlay();
    }
  }

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_currentOverlayEntry != null) {
      _removeCurrentOverlay();
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Фоновый слой для закрытия overlay при нажатии вне меню
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                _toggleTooltip();
              },
              behavior: HitTestBehavior.translucent,
              child: Container(),
            ),
          ),
          Positioned(
            top: offset.dy + size.height - 90,
            left: offset.dx - 15,
            child: Material(
              color: Colors.transparent,
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 242, 242, 242),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          _toggleTooltip();
                          final shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.white,
                              actionsAlignment: MainAxisAlignment.spaceEvenly,
                              
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Удалить сообщение?',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 18.35,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Вы уверены, что хотите удалить это сообщение?",
                                    //textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.black,
                                        fontFamily: 'Inter'),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                              actions: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: mainBlueColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Text(
                                      'Отмена',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                          fontFamily: 'Inter'),
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: mainBlueColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Text(
                                      'Удалить',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                          fontFamily: 'Inter'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (shouldDelete == true) {
                            widget.deleteMessage();
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/icon_delete_small.svg',
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Удалить',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color.fromARGB(255, 232, 39, 39),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          final text = widget.message;
                          if (text.isNotEmpty) {
                            Clipboard.setData(ClipboardData(text: text));
                          }
                          _toggleTooltip();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/icon_copy.svg',
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Копировать',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (_currentOverlayEntry != null) {
      _removeCurrentOverlay();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        if (_currentOverlayEntry != null) {
          _removeCurrentOverlay();
        }
        _toggleTooltip();
      },
      child: widget.child,
    );
  }
}
