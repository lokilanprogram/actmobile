import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/settings_notifier.dart';
import 'package:acti_mobile/configs/faq_provider.dart';
import 'package:acti_mobile/domain/api/events/events_api.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/screens/initial/initial_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/feedback/feedback_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/profile_menu/profile_menu_screen.dart';
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
import 'package:toastification/toastification.dart';
import 'package:acti_mobile/presentation/screens/profile/settings/user_agreement_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/settings/privacy_policy_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/settings/pd_agreement_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/settings/faq_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/settings/about_screen.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onBack;
  bool notificationsEnabled;

  SettingsScreen(
      {super.key, required this.onBack, required this.notificationsEnabled});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SettingsNotificationsProvider>(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAccountDeletedState) {
          developer.log('Аккаунт успешно удален', name: 'ACCOUNT_DELETE');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => InitialScreen()),
            (Route<dynamic> route) => false,
          );
        } else if (state is AuthFailure) {
          developer.log('Ошибка при удалении аккаунта: ${state.message}',
              name: 'ACCOUNT_DELETE');
          toastification.show(
            context: context,
            title: Text('Ошибка при удалении аккаунта: ${state.message}'),
            type: ToastificationType.error,
            style: ToastificationStyle.fillColored,
            autoCloseDuration: const Duration(seconds: 3),
            alignment: Alignment.topRight,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: widget.onBack,
          ),
          title: Text('Настройки',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w300)),
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Material(
            color: Colors.white,
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // const SizedBox(height: 45),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              children: [
                                CupertinoSwitch(
                                  activeTrackColor: Colors.blue,
                                  value: provider.notificationsEnabled,
                                  onChanged: (v) {
                                    provider.changeNotificationSettings(
                                        enabled: v);
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
                          _buildSettingsTile(
                              'Пользовательское соглашение',
                              () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const UserAgreementScreen()),
                                  )),
                          _buildSettingsTile(
                              'Политика конфиденциальности',
                              () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const PrivacyPolicyScreen()),
                                  )),
                          _buildSettingsTile(
                              'Согласие на обработку ПД',
                              () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const PdAgreementScreen()),
                                  )),
                          _buildSettingsTile(
                              'Часто задаваемые вопросы и ответы',
                              () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const FaqScreen()),
                                  )),
                          _buildSettingsTile(
                              'О нас',
                              () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AboutScreen()),
                                  )),
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
                                  developer.log(
                                      'Начало процесса удаления аккаунта',
                                      name: 'ACCOUNT_DELETE');
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
                          const SizedBox(height: 200),
                        ],
                      ),
                    ),
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
}
