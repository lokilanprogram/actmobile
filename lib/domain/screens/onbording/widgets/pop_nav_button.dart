import 'package:flutter/material.dart';

class PopNavButton extends StatelessWidget {
  final String text;
  final Function function;
  const PopNavButton({
    super.key, required this.text, required this.function,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        function();
      },
      child: Container(decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Color.fromRGBO(114,174,243,1)
        ),child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
          child: Text(text,style: TextStyle(color: Colors.white,fontSize: 17),),
        ),
      ),
    );
  }
}