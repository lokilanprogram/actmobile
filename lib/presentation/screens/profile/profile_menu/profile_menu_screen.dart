import 'dart:io';
import 'dart:ui';
import 'dart:developer' as developer;

import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/function.dart';
import 'package:acti_mobile/data/models/profile_model.dart';
import 'package:acti_mobile/data/models/similiar_users_model.dart';
import 'package:acti_mobile/domain/api/events/events_api.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/screens/initial/initial_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/map/map_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/public_user/screen/public_user_screen.dart';
import 'package:acti_mobile/presentation/widgets/blurred.dart';
import 'package:acti_mobile/presentation/widgets/popup_profile_buttons.dart';
import 'package:acti_mobile/presentation/widgets/build_interest_chip.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../update_profile/update_profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class ProfileMenuScreen extends StatefulWidget {
  const ProfileMenuScreen({super.key});

  @override
  State<ProfileMenuScreen> createState() => _ProfileMenuScreenState();
}

class SettingsPageProvider extends ChangeNotifier {
  int currentPage = 0; // 0 - main, 1 - соглашение, 2 - политика и т.д.
  bool notificationsEnabled = false;
  int? openedFaqIndex;

  void setPage(int page) {
    currentPage = page;
    notifyListeners();
  }

  void setNotifications(bool value) {
    notificationsEnabled = value;
    notifyListeners();
  }

  void setOpenedFaqIndex(int? idx) {
    openedFaqIndex = idx;
    notifyListeners();
  }
}

class _ProfileMenuScreenState extends State<ProfileMenuScreen> {
  bool isLoading = false;
  late ProfileModel profileModel;
  late List<SimiliarUsersModel> similiarUsersModel;
  bool showSettings = false;

  @override
  void initState() {
    initialize();
    super.initState();
  }

  initialize() {
    setState(() {
      isLoading = true;
    });
    context.read<ProfileBloc>().add(ProfileGetEvent());
  }

  void _openSettingsPage() {
    setState(() {
      showSettings = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) async {
        if (state is ProfileLogoutState) {
          setState(() {
            isLoading = false;
          });
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => InitialScreen()));
        }
        if (state is ProfileGotState) {
          setState(() {
            profileModel = state.profileModel;
            similiarUsersModel = state.similiarUsersModel;
          });

          if (!profileModel.isProfileCompleted) {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => UpdateProfileScreen(
                          profileModel: profileModel,
                        )));
          }
          setState(() {
            isLoading = false;
          });
        }
        if (state is ProfileLogoutErrorState) {
          setState(() {
            isLoading = false;
          });

          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Ошибка')));
        }
        if (state is ProfileGotErrorState) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Ошибка')));
        }
      },
      child: isLoading
          ? LoaderWidget()
          : Scaffold(
              backgroundColor: Colors.white,
              body: showSettings
                  ? ChangeNotifierProvider(
                      create: (_) => SettingsPageProvider(),
                      child: SettingsPage(
                        onBack: () {
                          setState(() {
                            showSettings = false;
                          });
                        },
                      ),
                    )
                  : Stack(
                      children: [
                        Positioned.fill(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    profileModel.photoUrl != null
                                        ? Image.network(profileModel.photoUrl!,
                                            width: double.infinity,
                                            height: 350,
                                            fit: BoxFit.cover, loadingBuilder:
                                                (BuildContext context,
                                                    Widget child,
                                                    ImageChunkEvent?
                                                        loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return SizedBox(
                                              height: 350,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: mainBlueColor,
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                ),
                                              ),
                                            );
                                          })
                                        : Image.asset(
                                            'assets/images/image_profile.png',
                                            width: double.infinity,
                                            height: 350,
                                            fit: BoxFit.cover,
                                          ),
                                    // Positioned(
                                    //   top: 77,
                                    //   right: 60,
                                    //   child: Icon(
                                    //       Icons.notifications_none_outlined,
                                    //       color: Colors.white),
                                    // ),
                                    Positioned(
                                        top: 48,
                                        right: 10,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 40,
                                              height: 40,
                                              child: Icon(
                                                  Icons
                                                      .notifications_none_outlined,
                                                  color: Colors.white),
                                            ),
                                            //const SizedBox(width: 8),
                                            PopUpProfileButtons(
                                              deleteFunction: () {
                                                setState(() {
                                                  isLoading = true;
                                                });
                                                context
                                                    .read<ProfileBloc>()
                                                    .add(ProfileLogoutEvent());
                                              },
                                              editFunction: () async {
                                                await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            UpdateProfileScreen(
                                                              profileModel:
                                                                  profileModel,
                                                            )));
                                              },
                                              settingsFunction:
                                                  _openSettingsPage,
                                            ),
                                          ],
                                        )),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: ClipRRect(
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                              sigmaX: 20, sigmaY: 20),
                                          child: Container(
                                            height: 120,
                                            padding: const EdgeInsets.only(
                                                left: 20, right: 20, top: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withOpacity(
                                                  0.3), // Тёмный полупрозрачный фон
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  profileModel.surname !=
                                                              null &&
                                                          profileModel
                                                                  .surname !=
                                                              ""
                                                      ? '${capitalize(profileModel.surname!)} ${capitalize(profileModel.name!)}'
                                                      : capitalize(profileModel
                                                              .name!) ??
                                                          'Неизвестное имя',
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  capitalize(
                                                      profileModel.status),
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 20,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  topRight:
                                                      Radius.circular(20)),
                                              color: Colors.white),
                                        )),
                                  ],
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 5),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Профиль',
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontFamily: 'Gilroy',
                                          fontWeight: FontWeight.bold,
                                          color: mainBlueColor,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      const Text(
                                        'О себе',
                                        style: TextStyle(
                                          fontSize: 16.67,
                                          fontFamily: 'Gilroy',
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        profileModel.bio == '' ||
                                                profileModel.bio == null
                                            ? '...'
                                            : profileModel.bio!,
                                        style: TextStyle(
                                            fontFamily: 'Inter', fontSize: 12),
                                      ),
                                      const SizedBox(height: 15),
                                      // Interests
                                      buildInterestsGrid(
                                        profileModel.categories
                                            .map((e) => e.name)
                                            .toList(),
                                      ),

                                      const SizedBox(height: 25),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 0),
                                        child: const Text(
                                          'Похожие пользователи',
                                          style: TextStyle(
                                            fontSize: 16.67,
                                            fontFamily: 'Gilroy',
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      // Similar users row
                                      Center(
                                          child: similiarUsersModel.isEmpty
                                              ? buildNoUsers()
                                              : SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.9,
                                                  child: Card(
                                                    elevation: 1.2,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        25)),
                                                    color: Colors.white,
                                                    child: buildSimiliarUsers(
                                                        context),
                                                  ),
                                                )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
    );
  }

  Padding buildSimiliarUsers(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: similiarUsersModel
            .take(4)
            .map((user) => GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PublicUserScreen(userId: user.id)));
                },
                child: buildAvatar(user.photoUrl, user.name ?? 'Неизвестный')))
            .toList(),
      ),
    );
  }

  Widget buildNoUsers() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.white70, width: 1),
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 1.2,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Text(
            'Здесь скоро появится список людей со схожими интересами',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Gilroy',
                fontSize: 15,
                color: mainBlueColor,
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  // Avatar widget
  Widget buildAvatar(String? path, String name) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: path == null
                ? AssetImage('assets/images/image_profile.png')
                : NetworkImage(path),
            radius: 32,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            name,
            style: TextStyle(
                fontFamily: 'Gilroy', fontSize: 9, fontWeight: FontWeight.w400),
          )
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  final VoidCallback onBack;

  const SettingsPage({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsPageProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Material(
              color: Colors.white,
              child: Stack(
                children: [
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 250),
                    child: provider.currentPage == 0
                        ? _buildMainSettings(context, provider)
                        : provider.currentPage == 4
                            ? _buildFaq(context, provider)
                            : _buildAgreement(context, provider),
                  ),
                  Positioned(
                    top: 40,
                    left: 16,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new),
                      onPressed: onBack,
                    ),
                  ),
                  if (provider.currentPage == 0)
                    Positioned(
                      top: 50,
                      right: 16,
                      child: Icon(Icons.check, color: Colors.green, size: 32),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainSettings(
      BuildContext context, SettingsPageProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 45),
          Center(
            child: Text('Настройки',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                CupertinoSwitch(
                  activeTrackColor: Colors.blue,
                  value: provider.notificationsEnabled,
                  onChanged: (v) async {
                    try {
                      provider.setNotifications(v);
                      await EventsApi().changeNotificationSettings(enabled: v);
                    } catch (e) {
                      provider.setNotifications(!v);
                      developer.log(
                          '[NOTIFICATIONS_SWITCH] Ошибка настройки уведомлений: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Ошибка настройки уведомлений: $e')),
                      );
                    }
                  },
                ),
                const SizedBox(width: 8),
                const Text('Уведомления', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
          const Divider(indent: 24, endIndent: 24),
          _buildSettingsTile(
              context, provider, 'Пользовательское соглашение', 1),
          _buildSettingsTile(
              context, provider, 'Политика конфиденциальности', 2),
          _buildSettingsTile(context, provider, 'Согласие на обработку ПД', 3),
          _buildSettingsTile(
              context, provider, 'Часто задаваемые вопросы и ответы', 4),
          _buildSettingsTile(context, provider, 'О нас', 5),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  side: BorderSide(color: Colors.black),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    isDismissible: false,
                    enableDrag: false,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const FeedbackPage(),
                  );
                },
                child: Text('Обратная связь',
                    style: TextStyle(fontSize: 18, color: Colors.black)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GestureDetector(
              onTap: () {
                context.read<ProfileBloc>().add(ProfileLogoutEvent());
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset('assets/icons/log-out.svg'),
                  SizedBox(width: 8),
                  Text('Выйти',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w300)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GestureDetector(
              onTap: () {
                showBlockDialog(context, 'Удалить профиль',
                    'Вы точно хотите удалить профиль без\nвозможности восстановления?',
                    () {
                  context.read<ProfileBloc>().add(ProfileDeleteEvent());
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
          const Spacer(),
          Center(
            child: Text('Версия 1.1.1.0',
                style: TextStyle(color: Colors.grey, fontSize: 15)),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, SettingsPageProvider provider,
      String title, int page) {
    return Column(
      children: [
        ListTile(
          title: Text(title, style: TextStyle(fontSize: 18)),
          trailing: Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () => provider.setPage(page),
        ),
        const Divider(height: 1, indent: 24, endIndent: 24),
      ],
    );
  }

  Widget _buildAgreement(BuildContext context, SettingsPageProvider provider) {
    return Column(
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
    );
  }

  Widget _buildFaq(BuildContext context, SettingsPageProvider provider) {
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
      // Добавьте остальные вопросы
    ];

    return Column(
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
        ...List.generate(faqs.length, (idx) {
          final isOpen = provider.openedFaqIndex == idx;
          return GestureDetector(
            onTap: () {
              provider.setOpenedFaqIndex(isOpen ? null : idx);
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        }),
      ],
    );
  }
}

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _controller = TextEditingController();
  XFile? _mediaFile;

  Future<void> _pickMedia() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _mediaFile = file;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Обратная связь',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Gilroy',
            fontWeight: FontWeight.w400,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Многострочное поле
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400, width: 1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 5,
                minLines: 4,
                decoration: InputDecoration(
                  hintText: 'О чём бы вы хотели рассказать?',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontFamily: 'Gilroy',
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Кнопка прикрепить медиафайл
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade400, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.white,
                ),
                onPressed: _pickMedia,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, color: Colors.grey[700], size: 28),
                    SizedBox(width: 10),
                    Text(
                      'Прикрепить медиафайл',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontFamily: 'Gilroy',
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_mediaFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_mediaFile!.path),
                    height: 80,
                  ),
                ),
              ),
            Spacer(),
            // Кнопка отправить
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4293EF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 18),
                  elevation: 0,
                ),
                onPressed: () {
                  // TODO: отправка обратной связи
                },
                child: Text(
                  'Отправить',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Gilroy',
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
