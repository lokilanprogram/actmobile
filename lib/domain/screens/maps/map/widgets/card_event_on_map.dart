import 'package:acti_mobile/domain/screens/maps/map/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CardEventOnMap extends StatelessWidget {
  const CardEventOnMap({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
     padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      
      
    ),
    child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: SvgPicture.asset('assets/icons/icon_divider_sheet.svg'),
          ),),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildHeader(),
              IconButton(onPressed: (){}, icon: Icon(Icons.more_vert))
            ],
          ),
          SizedBox(height: 16),
          Image.asset('assets/images/image_basketball_card.png'),
          SizedBox(height: 16),
          buildInfoRow(Icons.calendar_today, '20.10.2024 | 18:00 – 18:40'),
          SizedBox(height: 16),
          buildSpotsIndicator(),
          SizedBox(height: 38),
          SvgPicture.asset('assets/icons/icon_open.svg'),
          SizedBox(height: 32),
        ],
      ),
      );
  }
}