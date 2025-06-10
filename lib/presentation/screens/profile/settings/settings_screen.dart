import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/settings_notifier.dart';
import 'package:acti_mobile/configs/faq_provider.dart';
import 'package:acti_mobile/domain/api/events/events_api.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/screens/initial/initial_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/feedback/feedback_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/profile_menu/profile_menu_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/update_profile/update_profile_screen.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:developer' as developer;
import 'package:acti_mobile/domain/bloc/auth/auth_bloc.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onBack;
  bool notificationsEnabled;

  SettingsScreen(
      {super.key, required this.onBack, required this.notificationsEnabled});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SettingsNotificationsProvider>(context);

    return Scaffold(
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
                              value: provider.notificationsEnabled,
                              onChanged: (v) {
                                provider.changeNotificationSettings(enabled: v);
                              },
                            ),
                            const SizedBox(width: 8),
                            const Text('Уведомления',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w300,
                                    fontFamily: "Inter")),
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
                      _buildSettingsTile('Часто задаваемые вопросы и ответы',
                          () => _showFaq()),
                      _buildSettingsTile('О нас', () => _showAgreement()),
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
                              padding: const EdgeInsets.symmetric(vertical: 18),
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
                                fontFamily: 'Inter',
                                fontSize: 17,
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
                                    fontFamily: 'Inter_Light',
                                    fontSize: 19,
                                    fontWeight: FontWeight.w300,
                                  )),
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
                              // context
                              //     .read<AuthBloc>()
                              //     .add(AuthDeleteAccountEvent());
                            });
                          },
                          child: Row(
                            children: [
                              SvgPicture.asset('assets/icons/trash.svg'),
                              SizedBox(width: 8),
                              Text('Удалить профиль',
                                  style: TextStyle(
                                    fontFamily: 'Inter_Light',
                                    fontSize: 19,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.red,
                                  )),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Text('Версия 1.1.1.0',
                            style: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Inter_Light',
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                            )),
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
    );
  }

  Widget _buildSettingsTile(String title, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          title: Text(title,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  fontFamily: "Inter")),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => FaqProvider()..loadFaqs(),
        child: Consumer<FaqProvider>(
          builder: (context, faqProvider, child) {
            if (faqProvider.isLoading ?? false) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (faqProvider.error != null) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Center(
                  child: Text('Ошибка загрузки: ${faqProvider.error}'),
                ),
              );
            }

            final faqs = faqProvider.faqs ?? [];
            return Container(
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
                        final isOpen = faqProvider.openedFaqIndex == idx;
                        return GestureDetector(
                          onTap: () => faqProvider.toggleFaq(idx),
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
                                        faqs[idx].question,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      isOpen
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      size: 28,
                                    ),
                                  ],
                                ),
                                if (isOpen) ...[
                                  Divider(height: 24, color: Colors.blue[100]),
                                  Text(
                                    'Ответ:',
                                    style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 26, 107, 199),
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    faqs[idx].answer,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10,
                                        height: 1),
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
            );
          },
        ),
      ),
    );
  }
}
