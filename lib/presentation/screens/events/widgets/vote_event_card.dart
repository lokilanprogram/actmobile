import 'package:flutter/material.dart';
import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/data/models/all_events_model.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class VoteEventCard extends StatelessWidget {
  final VoteModel vote;
  final VoidCallback? onTap;

  const VoteEventCard({super.key, required this.vote, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              child: vote.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: vote.imageUrl,
                      width: 110,
                      height: 90,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 110,
                          height: 90,
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 110,
                        height: 90,
                        color: Colors.grey[200],
                        child:
                            Icon(Icons.error_outline, color: Colors.grey[400]),
                      ),
                    )
                  : Container(
                      width: 110,
                      height: 90,
                      color: Colors.grey[200],
                    ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vote.title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (vote.is18plus)
                        Container(
                          margin: EdgeInsets.only(left: 6),
                          padding:
                              EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('18+',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${vote.date} | ${vote.time}',
                    style: TextStyle(
                        color: mainBlueColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.check, color: Colors.green, size: 22),
                      const SizedBox(width: 4),
                      Text(
                        '${vote.votes} ГОЛОС${vote.votes == 1 ? '' : (vote.votes < 5 && vote.votes > 1 ? 'А' : 'ОВ')}',
                        style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
