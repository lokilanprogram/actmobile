import 'package:flutter/material.dart';

class ErrorWidgetWithRetry extends StatelessWidget {
  final VoidCallback onRetry;

  const ErrorWidgetWithRetry({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 25,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20,),
            const Text(
              'Что-то пошло не так',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Gilroy',
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Text(
              'Проверьте доступ к интернету',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Inter',
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4D8CFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 8,
                ),
              ),
              child: const Text(
                'Обновить',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }
}
