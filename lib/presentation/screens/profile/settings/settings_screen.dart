import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/domain/api/events/events_api.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/screens/initial/initial_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/feedback/feedback_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/update_profile/update_profile_screen.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:developer' as developer;
import 'package:acti_mobile/domain/bloc/auth/auth_bloc.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onBack;
  const SettingsScreen({super.key, required this.onBack});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = false;
  int? openedFaqIndex;

  void _showBlockDialog(BuildContext context, String title, String message,
      VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(title),
          content: Text(message),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4293EF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  ),
                  child: Text(
                    'Нет',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4293EF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  ),
                  child: Text(
                    'Да',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            // TextButton(
            //   child: Text('Отмена'),
            //   onPressed: () {
            //     Navigator.of(context).pop();
            //   },
            // ),
            // TextButton(
            //   child: Text('Подтвердить', style: TextStyle(color: Colors.red)),
            //   onPressed: () {
            //     Navigator.of(context).pop();
            //     onConfirm();
            //   },
            // ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAccountDeletedState) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => InitialScreen()),
            (Route<dynamic> route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Material(
            color: Colors.white,
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 45),
                        Center(
                          child: Text('Настройки',
                              style: TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: [
                              CupertinoSwitch(
                                activeTrackColor: Colors.blue,
                                value: notificationsEnabled,
                                onChanged: (v) async {
                                  try {
                                    setState(() {
                                      notificationsEnabled = v;
                                    });
                                    await EventsApi()
                                        .changeNotificationSettings(enabled: v);
                                  } catch (e) {
                                    setState(() {
                                      notificationsEnabled = !v;
                                    });
                                    developer.log(
                                        '[NOTIFICATIONS_SWITCH] Ошибка настройки уведомлений: $e');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Ошибка настройки уведомлений: $e')),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(width: 8),
                              const Text('Уведомления',
                                  style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        ),
                        const Divider(indent: 24, endIndent: 24),
                        _buildSettingsTile('Пользовательское соглашение',
                            () => _showAgreement()),
                        _buildSettingsTile('Политика конфиденциальности',
                            () => _showAgreement()),
                        _buildSettingsTile(
                            'Согласие на обработку ПД', () => _showAgreement()),
                        _buildSettingsTile('FAQ', () => _showFaq()),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 22, horizontal: 24),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Colors.black, width: 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                backgroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FeedbackScreen()),
                                );
                              },
                              child: const Text(
                                'Обратная связь',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Gilroy',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: GestureDetector(
                            onTap: () {
                              context
                                  .read<ProfileBloc>()
                                  .add(ProfileLogoutEvent());
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset('assets/icons/log-out.svg'),
                                SizedBox(width: 8),
                                Text('Выйти',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w300)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: GestureDetector(
                            onTap: () {
                              _showBlockDialog(context, 'Удалить профиль',
                                  'Вы точно хотите удалить профиль без\nвозможности восстановления?',
                                  () {
                                context
                                    .read<AuthBloc>()
                                    .add(AuthDeleteAccountEvent());
                              });
                            },
                            child: Row(
                              children: [
                                SvgPicture.asset('assets/icons/trash.svg'),
                                SizedBox(width: 8),
                                Text('Удалить профиль',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.red,
                                        fontWeight: FontWeight.w300)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Text('Версия 1.1.1.0',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 15)),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new),
                    onPressed: widget.onBack,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(String title, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          title: Text(title, style: TextStyle(fontSize: 18)),
          trailing: Icon(Icons.arrow_forward_ios, size: 18),
          onTap: onTap,
        ),
        const Divider(height: 1, indent: 24, endIndent: 24),
      ],
    );
  }

  void _showAgreement() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 48),
            Center(
              child: Text('Условия использования',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Gilroy")),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                        text: 'Acti',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text:
                            ' — это приложение, которое помогает пользователям находить мероприятия по их увлечениям.\n\n'),
                    TextSpan(
                        text:
                            'Пользователи находят здесь разнообразные мероприятия — мастер-классы, спортивные тренировки, культурные события и многое другое. Всего в Acti представлено более 3 000 000 мероприятий по 900 различным категориям.\n\n'),
                    TextSpan(
                        text:
                            'Организаторы мероприятий и частные специалисты находят с помощью Acti заинтересованных участников. Каждый день в нашем приложении появляется более 25 тысяч новых предложений.\n\n'),
                    TextSpan(
                        text:
                            'Как пользователю выбрать мероприятие?\nКак организатору найти участников?'),
                  ],
                ),
                style: TextStyle(fontSize: 17, height: 1.4),
              ),
            ),
            const Spacer(),
            Center(
              child: Text('Версия 1.1.1.0',
                  style: TextStyle(color: Colors.grey, fontSize: 15)),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showFaq() {
    final faqs = [
      {
        'q': 'Когда будет обновление?',
        'a':
            'На данный момент мы занимаемся этим.\nОжидать новой версии приложения нужно летом этого года.\nМы рады, что вы с нами и ждёте новых возможностей!',
      },
      {
        'q': 'Зачем мне это приложение',
        'a':
            'Это приложение помогает находить интересные мероприятия и единомышленников.',
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 60.0, right: 16),
                child: Text(
                  'Часто задаваемые вопросы и ответы',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Gilroy"),
                  maxLines: 2,
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: faqs.length,
                itemBuilder: (context, idx) {
                  final isOpen = openedFaqIndex == idx;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        openedFaqIndex = isOpen ? null : idx;
                      });
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      padding: EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Color(0xFFEAF3FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  faqs[idx]['q']!,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Icon(
                                isOpen ? Icons.expand_less : Icons.expand_more,
                                size: 28,
                              ),
                            ],
                          ),
                          if (isOpen) ...[
                            Divider(height: 24, color: Colors.blue[100]),
                            Text(
                              'Ответ:',
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              faqs[idx]['a']!,
                              style: TextStyle(fontSize: 16, height: 1.3),
                            ),
                          ]
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
