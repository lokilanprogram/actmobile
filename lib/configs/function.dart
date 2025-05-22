import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/presentation/screens/maps/event/widgets/card_event_on_map.dart';
import 'package:acti_mobile/presentation/widgets/report_sheet_widget.dart';
import 'package:acti_mobile/presentation/widgets/report_user_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

Future<void> addUserIconToStyle(MapboxMap mapboxMap) async {
  final ByteData bytes = await rootBundle.load('assets/icons/icon_current_location.png');
  final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List());
  final frame = await codec.getNextFrame();
  final ui.Image image = frame.image;

  // Преобразуем ui.Image → MbxImage
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) return;

  final Uint8List imageBytes = byteData.buffer.asUint8List();

  final mbxImage = MbxImage(
    width: image.width,
    height:image.height,
    data: imageBytes,
  );

  // Добавляем изображение в стиль карты
  await mapboxMap.style.addStyleImage(
    'custom-user-icon', // imageId
    1, // scale
    mbxImage,
    false, // sdf (если true — будет воспринимать как монохромную иконку)
    [], // stretchX
    [], // stretchY
    null, // content
  );

  // Устанавливаем пользовательскую иконку
  await mapboxMap.location.updateSettings(
    LocationComponentSettings(
      enabled: true,
      locationPuck: LocationPuck(
        locationPuck2D: LocationPuck2D(
        bearingImage: imageBytes,
        topImage: imageBytes
      ),
      )
    ),
  );
  }
  void showCardEventMapBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CardEventOnMap());
}
Widget buildOption(String text, BuildContext context, Function function) {
  return Column(
    children: [
      ListTile(
        title: Text(
          text,
          style: TextStyle(fontSize: 20,fontFamily: 'Inter', color: Colors.black),
        ),
        trailing:SvgPicture.asset('assets/icons/icon_block_arrow.svg'),
        onTap: () {
          function();
        },
      ),
      Divider(height: 1, thickness: 0.5),
    ],
  );
}
void showSpecificReportBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    backgroundColor: Colors.white,
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (_, controller) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indicator
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),

                // Title
                const Text(
                  'Что именно вам кажется\nнедопустимым в этом мероприятии?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,fontFamily: 'Inter',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),


                // Learn more
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: TextButton(
                    onPressed: () {
                      // Навигация к правилам
                    },
                    child: Text.rich(
                      TextSpan(
                        text: 'Узнайте больше ',
                        style: TextStyle(color: Colors.blue,fontFamily: 'Inter',fontSize: 13),
                        children: [
                          TextSpan(
                            text: 'о правилах Acti',
                            style: TextStyle(color: Colors.black,fontFamily: 'Inter',fontSize: 13),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void showReportUserBottomSheet(BuildContext context,String userId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    backgroundColor: Colors.white,
    builder: (context) {
      return ReportUserSheetWidget(userId: userId,);
    },
  );
}


void showReportEventBottomSheet(BuildContext context,String eventId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    backgroundColor: Colors.white,
    builder: (context) {
      return ReportEventSheetWidget(eventId: eventId,);
    },
  );
}

void  showKidsAlertDialog(BuildContext context, String? subtitle,{bool isTitled = false, String title = ''} ) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Заголовок
              Text(
                'Будьте бдительны',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              // Текст с выделением
              RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  children: [
                    TextSpan(
                      text: 'Выбирая этот фильтр вы позволяете прийти на событие с детьми. ',
                       style: TextStyle(
                      fontWeight: FontWeight.w300,fontFamily: 'Inter_Light',fontSize: 14
                    )
                    ),
                    TextSpan(
                      text: 'Дети — это здорово! ',
                      style: TextStyle(fontWeight: FontWeight.w500,fontFamily: 'Inter',fontSize: 14),
                    ),
                       TextSpan(
                      text: 'Но важно помнить, ',
                      style: TextStyle(fontWeight: FontWeight.w500,fontFamily: 'Inter',fontSize: 14),
                    ),
                    TextSpan(
                      text:
                          'что такие события требуют немного больше заботы:\n\n'
                          '— Убедитесь, что формат подходит для детей;\n'
                          '— Постарайтесь избегать тем и контента, не предназначенных для детей;\n'
                          '— Соблюдайте правила безопасности и действующие законы.',
                    style: TextStyle(
                      fontWeight: FontWeight.w300,fontFamily: 'Inter_Light',fontSize: 14
                    )
                    ),
                    TextSpan(
                      text: '\n\nОрганизатор всегда задаёт тон мероприятию — пусть оно будет комфортным и безопасным для всех, особенно для самых маленьких!',
                         style: TextStyle(
                      fontWeight: FontWeight.w300,fontFamily: 'Inter_Light',fontSize: 14
                    )
                    )
                  ],
                ),
              ),
              SizedBox(height: 24),
              // Кнопка
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Цвет кнопки
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Понимаю',
                    style: TextStyle(fontSize: 16, color: Colors.white,fontFamily: 'Inter'),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

}


void  showAlertOKDialog(BuildContext context, String? subtitle,{bool isTitled = false, String title = ''} ) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (context) {
      return Dialog(backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              isTitled?Text(
               title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.35, fontWeight: FontWeight.w700,
                fontFamily: 'Inter'),
              ):Container(),
               SizedBox(height:isTitled ? 8: 0),
             subtitle == null?Container(): Text(
               subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300,
                fontFamily: 'Inter'),
              ),
               SizedBox(height:isTitled ? 14: 24),
              SizedBox(
                width: double.infinity,
                height: 59,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainBlueColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'ОК',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontFamily: 'Inter'),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showCancelActivityDialog(BuildContext context,String desctiption,String optionOne, 
String optionTwo,  Function cancelOne, Function cancelAll) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (context) {
      return Dialog(backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Padding(
          padding: const EdgeInsets.only(left: 26,right: 26,bottom: 20),
          child:  Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align( alignment: Alignment.topRight,
                  child: IconButton(onPressed: (){
                    Navigator.pop(context);
                  }, icon: Icon(Icons.close))),
                 Text(
                  desctiption,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w100,
                  color: Colors.black,
                  fontFamily: 'Inter'),
                ),
                const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: mainBlueColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 5),
        ),
        onPressed: () {
         Navigator.pop(context);
         cancelOne();
        },
        child:  Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            optionOne,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500,
            color: Colors.white,
            fontFamily: 'Inter'),
          ),
        ),
      
    ),
                  ),
                  SizedBox(width: 20,),
                        Expanded(
                          child: ElevatedButton(
        style: ElevatedButton.styleFrom( backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 5),
        ),
        onPressed: () {
          Navigator.pop(context);
          cancelAll();
        },
        child:  Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            optionTwo,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500,
            color: Colors.blue,
            fontFamily: 'Inter'),
          ),
        ),
      
    ),
                        ),
              ],)
              ],
            ),
          
        ),
      );
    },
  );
}

void showBlockDialog(BuildContext context, String name, Function function) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (context) {
      return Dialog(backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 26),
          child:  Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Блокировка пользователя',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18.35, fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontFamily: 'Inter'),
                ),
                const SizedBox(height: 12),
                 Text(
                  'Вы точно хотите заблокировать пользователя $name?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300,
                  color: Colors.black,
                  fontFamily: 'Inter'),
                ),
                const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ActionDialogWidget(
                          function: (){
                            function();
                            Navigator.pop(context);
                          },
                          text: 'Да',
                        ),
                  ),
                  SizedBox(width: 20,),
                        Expanded(
                          child: ActionDialogWidget(
                          function: (){
                            Navigator.pop(context);
                          },
                          text: 'Нет',
                                                ),
                        ),
              ],)
              ],
            ),
          
        ),
      );
    },
  );
}

class ActionDialogWidget extends StatelessWidget {
  final String text;
  final Function function;
  const ActionDialogWidget({
    super.key, required this.text, required this.function,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: mainBlueColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onPressed: () {
          function();
        },
        child:  Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            text,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500,
            color: Colors.white,
            fontFamily: 'Inter'),
          ),
        ),
      
    );
  }
}


  Future<void> addPoint(MapboxMap mapboxMap, LatLngInfo latlng,String imagePath )async{
    final unit8list = await loadMbxImage(mapboxMap, imagePath);
    final pointAnnotationManager = await mapboxMap.annotations.createPointAnnotationManager();
    
final pointAnnotation = PointAnnotationOptions(
  geometry: Point(coordinates: Position(latlng.longitude, latlng.latitude)),
  image: unit8list, // ID иконки
  iconSize: 2.5,              // Можно масштабировать иконку
);

    await pointAnnotationManager.create(pointAnnotation);
  }
  
  class LatLngInfo {
    final double latitude;
    final double longitude;

  LatLngInfo({required this.latitude, required this.longitude});
  }

  Future<Uint8List> loadMbxImage(MapboxMap mapboxMap, String assetPath) async {
  final byteData = await rootBundle.load(assetPath);
  final codec = await ui.instantiateImageCodec(byteData.buffer.asUint8List());
  final frame = await codec.getNextFrame();
  final image = await frame.image.toByteData(format: ui.ImageByteFormat.png);
  final mbxImage =  MbxImage(
    width: frame.image.width,
    height: frame.image.height,
    data: image!.buffer.asUint8List(),
  );
  await mapboxMap.style.addStyleImage(
  'marker-basketball',   // ID
  2.5,                   // scale
  mbxImage,          // см. ниже, как получить MbxImage
  false,
  [],
  [],
  null,
);
   return image.buffer.asUint8List();
}

