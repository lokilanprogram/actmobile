import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/constants.dart';
import 'package:flutter/material.dart';

class ProfileMenuScreen extends StatelessWidget {
  const ProfileMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  SingleChildScrollView(
          child: Column(
            children: [
              // Top Image with name and status
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                         topRight: Radius.circular(25),
                        topLeft: Radius.circular(25),
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25)),
                    child: Image.asset(
                      'assets/images/image_profile.png',
                      width: double.infinity,
                      height: 350,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 70,
                    left: 16,
                    child: Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                  Positioned(
                    top: 70,
                    right: 60,
                    child: Icon(Icons.notifications_none_outlined,
                        color: Colors.white),
                  ),
                  Positioned(
                    top: 70,
                    right: 16,
                    child: Icon(Icons.more_vert, color: Colors.white),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Анастасия',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        
                        Text(
                          'Online',
                          style: TextStyle(
                            fontSize: 20,fontFamily: 'Inter',
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Профиль',
                      style: TextStyle(
                        fontSize: 25,fontFamily: 'Gilroy',
                        fontWeight: FontWeight.bold,
                        color: mainBlueColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'О себе',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Меня зовут Анастасия. Я открыта к общению и всегда готова узнавать новое. У меня разносторонние интересы, и я стараюсь развиваться в разных направлениях. Надеюсь найти здесь новых друзей и интересные знакомства.',
                      style: TextStyle(fontSize: 12,fontFamily: 'Inter',height: 1.2),
                    ),
                    const SizedBox(height: 20),

                    // Interests
                    Center(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildInterestChip('Выставки и театры'),
                          _buildInterestChip('Музыка'),
                          _buildInterestChip('Игры'),
                          _buildInterestChip('Гимнастика'),
                          _buildInterestChip('Еда'),
                          _buildInterestChip('Технологии'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: const Text(
                        'Похожие пользователи',
                        style:
                            TextStyle(fontSize: 15, fontWeight: FontWeight.w700,fontFamily: 'Gilroy'),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Similar users row
                    Center(
                        child: ClipRRect(
                          child: Card(elevation: 1.2,color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                                  child: Row(mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(similarUsers.length, (index) {
                                        final user = similarUsers[index];
                                        return _buildAvatar(user['image']!, user['name']!);
                                      }),
                                    ),
                                ),
                              ),
                        ),
                      ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
);
  }

  // Interest chip
  Widget _buildInterestChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF4A8EFF)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: mainBlueColor,fontSize: 11, fontFamily: 'Gilroy'),
      ),
    );
  }

  // Avatar widget
  Widget _buildAvatar(String path,String name) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(path),
            radius: 28,
          ),
          SizedBox(height: 10,),
          Text(name,style: TextStyle(fontFamily: 'Gilroy',fontSize: 9,fontWeight: FontWeight.w400),)
        ],
      ),
    );
  }
}
