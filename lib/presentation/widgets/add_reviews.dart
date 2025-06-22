import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/data/models/profile_event_model.dart';
import 'package:acti_mobile/data/models/reviews_model.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

void showAddReviewsBottomSheet(
    BuildContext context, String userId, OrganizedEventModel eventModel) {
  showModalBottomSheet<void>(
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - 240,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 66, 147, 239),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SvgPicture.asset(
                          'assets/icons/icon_completed.svg',
                          width: 23,
                          height: 23,
                        ),
                        SizedBox(width: 10),
                        const Text(
                          'Мероприятие завершено!',
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Gilroy',
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      '${DateFormat('dd.MM.yyyy').format(eventModel.dateStart)} | ${eventModel.address}',
                      style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Gilroy',
                          fontWeight: FontWeight.w400,
                          color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    height: MediaQuery.of(context).size.height - 280,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: 30),
                          Text(
                            'Оцените мероприятие',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Gilroy',
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 20),
                          FormReviews(eventId: eventModel.id),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class FormReviews extends StatefulWidget {
  final String eventId;

  const FormReviews({
    super.key,
    required this.eventId,
  });

  @override
  State<FormReviews> createState() => _FormReviewsState();
}

class _FormReviewsState extends State<FormReviews> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _showRatingError = false;
  bool _showCommentError = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview() {
    setState(() {
      _showRatingError = _rating == 0;
      _showCommentError = _commentController.text.trim().isEmpty;
    });

    if (!_showRatingError && !_showCommentError) {
      final reviewPost = ReviewPost(
        rating: _rating,
        comment: _commentController.text,
      );

      context.read<ProfileBloc>().add(
            ProfilePostReviewEvent(
              reviewPost: reviewPost,
              eventId: widget.eventId,
            ),
          );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfilePostedReviewErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorText),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = index + 1;
                    _showRatingError = false;
                  });
                },
                child: SvgPicture.asset(
                  'assets/icons/icon_star_new.svg',
                  width: 49.47,
                  height: 47.47,
                  color: index >= _rating
                      ? const Color.fromARGB(255, 207, 207, 207)
                      : null,
                ),
              );
            }),
          ),
          if (_showRatingError)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Пожалуйста, выберите оценку',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontFamily: 'Gilroy',
                ),
              ),
            ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 246, 246, 246),
              borderRadius: BorderRadius.circular(30),
              border: _showCommentError ? Border.all(color: Colors.red) : null,
            ),
            child: TextField(
              textCapitalization: TextCapitalization.sentences,
              controller: _commentController,
              maxLines: 6,
              onChanged: (value) {
                if (_showCommentError) {
                  setState(() {
                    _showCommentError = value.trim().isEmpty;
                  });
                }
              },
              decoration: InputDecoration(
                hintText: 'Расскажите о своих впечателениях',
                hintStyle: TextStyle(
                  fontFamily: 'Gilroy',
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  color: Colors.black,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
              ),
            ),
          ),
          if (_showCommentError)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Пожалуйста, напишите комментарий',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontFamily: 'Gilroy',
                ),
              ),
            ),
          const SizedBox(height: 20),
          Material(
            elevation: 1.2,
            borderRadius: BorderRadius.circular(30),
            child: GestureDetector(
              onTap: _submitReview,
              child: Container(
                height: 59,
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 246, 246, 246),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    'Отправить',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Gilroy',
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Пропустить",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: mainBlueColor,
                fontFamily: 'Gilroy',
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
