import 'dart:io';

import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/date_utils.dart';
import 'package:acti_mobile/data/models/message_model.dart';
import 'package:acti_mobile/presentation/screens/maps/public_user/screen/public_user_screen.dart';
import 'package:acti_mobile/presentation/widgets/full_image_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({
    super.key,
    required this.isPrivateChats,
    required this.message,
    required this.currentUserId,
    this.special = false,
    this.interlocutorUserId,
    this.highlightText,
    required this.isHighlighted,
    required this.isReaded,
    required this.orgId,
  });

  final String? interlocutorUserId;
  final bool isPrivateChats;
  final MessageModel message;
  final bool special;
  final String currentUserId;
  final String? highlightText;
  final bool isHighlighted;
  final bool isReaded;
  final String? orgId;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final size = MediaQuery.of(context).size;
    final hasAttachment = widget.message.attachmentUrl != null;
    final isSentMessageCard = widget.currentUserId == widget.message.userId;
    final messageHasText = widget.message.content.isNotEmpty;

    int padding = 2;

    if (isSentMessageCard) {
      padding = Platform.isAndroid
          ? (widget.special ? 13 : 12)
          : (widget.special ? 17 : 16);
    } else {
      padding = Platform.isAndroid ? 8 : 12;
    }

    final textPadding = '\u00A0' * (padding + 2);
    final maxWidth = MediaQuery.of(context).size.width * 0.80;
    final maxHeight = MediaQuery.of(context).size.height * 0.40;
    final minWidth = 0.8 * maxWidth;

    return Align(
      alignment:
          isSentMessageCard ? Alignment.centerRight : Alignment.centerLeft,
      child: ClipPath(
        clipper: widget.special
            ? TriangleClipper(isSender: isSentMessageCard)
            : null,
        child: Container(
          constraints: BoxConstraints(
            minHeight: 34,
            minWidth: widget.special ? (isSentMessageCard ? 98 : 76) : 60,
            maxWidth: hasAttachment
                ? MediaQuery.of(context).size.width * 0.7
                : size.width * 0.80 + (widget.special ? 10 : 0),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: widget.special && !isSentMessageCard
                  ? const Radius.circular(4)
                  : const Radius.circular(12.0),
              topRight: widget.special && isSentMessageCard
                  ? const Radius.circular(4)
                  : const Radius.circular(12.0),
              bottomLeft: const Radius.circular(12.0),
              bottomRight: const Radius.circular(12.0),
            ),
            color: isSentMessageCard
                ? Color.fromARGB(255, 0, 171, 253)
                : Color.fromARGB(255, 221, 221, 221),
          ),
          margin: EdgeInsets.only(
            bottom: 3.0,
            top: widget.special ? 6.0 : 0,
            left: widget.special ? 6 : 16.0,
            right: widget.special ? 6 : 16.0,
          ),
          padding: hasAttachment
              ? EdgeInsets.only(
                  top: 4.0,
                  bottom: 4.0,
                  left: widget.special && !isSentMessageCard ? 14.0 : 4.0,
                  right: widget.special && isSentMessageCard ? 14.0 : 4.0,
                )
              : EdgeInsets.only(
                  left: 10,
                  right: widget.special && isSentMessageCard ? 16 : 10,
                  top: 4,
                  bottom: 6,
                ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasAttachment) ...[
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 300,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FullImageScreen(
                                  imageUrl: widget.message.attachmentUrl!),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(widget.message.attachmentUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 300, loadingBuilder:
                                  (BuildContext context, Widget child,
                                      ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              height: 300,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                  if (messageHasText) ...[
                    Padding(
                      padding: hasAttachment
                          ? const EdgeInsets.only(left: 4.0, top: 4.0)
                          : widget.special && !isSentMessageCard
                              ? EdgeInsets.only(
                                  left: 10,
                                  top: 4,
                                  bottom: padding == 0 ? 14.0 : 0,
                                )
                              : EdgeInsets.only(
                                  top: 2.0,
                                  bottom: padding == 0 ? 14.0 : 0,
                                ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.isPrivateChats == false &&
                              !isSentMessageCard)
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PublicUserScreen(
                                            userId: widget.message.userId)));
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.message.user.name,
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontFamily: 'Gilroy',
                                        fontWeight: FontWeight.w700,
                                        color: mainBlueColor,
                                        fontSize: 12),
                                  ),
                                  if (widget.orgId == widget.message.userId &&
                                      widget.isPrivateChats == false) ...[
                                    Icon(
                                      Icons.star,
                                      color: Color.fromARGB(255, 239, 178, 66),
                                      size: 13,
                                      weight: 700,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          RichText(
                            maxLines: null,
                            text: TextSpan(
                              children: [
                                ..._highlightOccurrences(
                                  widget.message.content,
                                  widget.highlightText,
                                  !isSentMessageCard
                                      ? Colors.black
                                      : Colors.white,
                                ),
                                WidgetSpan(
                                  child: IgnorePointer(
                                    child: Opacity(
                                      opacity: 0,
                                      child: Text(
                                        textPadding,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.transparent,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ],
              ),
              Positioned(
                right: widget.special && isSentMessageCard && messageHasText
                    ? -6
                    : 0,
                bottom: -1,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      if (!messageHasText && hasAttachment) ...[
                        const BoxShadow(
                          color: Color.fromARGB(174, 1, 4, 21),
                          blurRadius: 20,
                        )
                      ],
                    ],
                  ),
                  margin: !messageHasText && hasAttachment
                      ? const EdgeInsets.all(4.0)
                      : null,
                  padding: !messageHasText && hasAttachment
                      ? const EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 2.0,
                        )
                      : null,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        formattedTimestamp(
                          widget.message.createdAt,
                          true,
                          Platform.isIOS,
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Gilroy',
                          color:
                              !isSentMessageCard ? Colors.black : Colors.white,
                        ),
                      ),
                      if (widget.message.status == "read" && isSentMessageCard)
                        const SizedBox(width: 4),
                      if (widget.message.status == "read" && isSentMessageCard)
                        SvgPicture.asset('assets/icons/icon_message_read.svg'),
                      // if (isSentMessageCard) ...[
                      //   const SizedBox(
                      //     width: 2.0,
                      //   ),
                      //   Image.asset(
                      //     'assets/images/${widget.message.status.value}.png',
                      //     color: widget.message.status.value != 'SEEN'
                      //         ? messageHasText
                      //             ? colorTheme.textColor1
                      //                 .withOpacity(0.65)
                      //                 .withBlue(Theme.of(context).brightness ==
                      //                         Brightness.dark
                      //                     ? 255
                      //                     : 150)
                      //             : Theme.of(context).brightness ==
                      //                     Brightness.dark
                      //                 ? Colors.white
                      //                 : colorTheme.textColor1
                      //                     .withOpacity(0.7)
                      //                     .withBlue(
                      //                       Theme.of(context).brightness ==
                      //                               Brightness.dark
                      //                           ? 255
                      //                           : 100,
                      //                     )
                      //         : null,
                      //     width: 16.0,
                      //   ),
                      // ],
                      if (widget.special &&
                          isSentMessageCard &&
                          messageHasText) ...[const SizedBox(width: 9)],
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<InlineSpan> _highlightOccurrences(
      String source, String? query, Color baseColor) {
    if (query == null || query.trim().isEmpty) {
      return [
        TextSpan(
            text: source,
            style: TextStyle(
                color: baseColor,
                fontFamily: 'Gilroy',
                fontSize: 14,
                fontWeight: FontWeight.w500))
      ];
    }

    final matches =
        RegExp(RegExp.escape(query), caseSensitive: false).allMatches(source);
    if (matches.isEmpty) {
      return [
        TextSpan(
            text: source,
            style: TextStyle(
                color: baseColor,
                fontFamily: 'Gilroy',
                fontSize: 14,
                fontWeight: FontWeight.w500))
      ];
    }

    final spans = <TextSpan>[];
    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: source.substring(lastIndex, match.start),
          style: TextStyle(
              color: baseColor,
              fontFamily: 'Gilroy',
              fontSize: 14,
              fontWeight: FontWeight.w500),
        ));
      }

      spans.add(TextSpan(
        text: source.substring(match.start, match.end),
        style: TextStyle(
          color: baseColor,
          backgroundColor: const Color.fromARGB(255, 255, 238, 82),
          fontWeight: FontWeight.bold,
          fontFamily: 'Gilroy',
          fontSize: 14,
        ),
      ));

      lastIndex = match.end;
    }

    if (lastIndex < source.length) {
      spans.add(TextSpan(
        text: source.substring(lastIndex),
        style: TextStyle(
          color: baseColor,
          fontFamily: 'Gilroy',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ));
    }

    return spans;
  }
}

class TriangleClipper extends CustomClipper<Path> {
  final bool isSender;

  TriangleClipper({required this.isSender});

  @override
  Path getClip(Size size) {
    final path = Path();
    if (isSender) {
      path.lineTo(size.width, 0);
      path.lineTo(size.width, 4);
      path.lineTo(size.width - 16, 16);
      path.lineTo(size.width - 16, size.height - 10);
      path.quadraticBezierTo(
          size.width - 16, size.height - 2, size.width - 36, size.height);
      path.lineTo(0, size.height);
    } else {
      path.lineTo(0, 4);
      path.lineTo(16, 16);
      path.lineTo(16, size.height - 10);
      path.quadraticBezierTo(16, size.height - 2, 36, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
