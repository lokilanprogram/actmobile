import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acti_mobile/configs/faq_provider.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FaqProvider()..loadFaqs(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Часто задаваемые вопросы и ответы',
              maxLines: 2,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  fontFamily: "Inter")),
        ),
        body: Consumer<FaqProvider>(
          builder: (context, faqProvider, child) {
            if (faqProvider.isLoading ?? false) {
              return const Center(child: CircularProgressIndicator());
            }
            if (faqProvider.error != null) {
              return Center(
                  child: Text('Ошибка загрузки: ${faqProvider.error}'));
            }
            final faqs = faqProvider.faqs ?? [];
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              itemCount: faqs.length,
              itemBuilder: (context, idx) {
                final isOpen = faqProvider.openedFaqIndex == idx;
                return GestureDetector(
                  onTap: () => faqProvider.toggleFaq(idx),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3FF),
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
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
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
                          const Text(
                            'Ответ:',
                            style: TextStyle(
                                color: Color.fromARGB(255, 26, 107, 199),
                                fontWeight: FontWeight.w400,
                                fontSize: 12),
                          ),
                          SizedBox(height: 4),
                          Text(
                            faqs[idx].answer,
                            style: const TextStyle(
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
            );
          },
        ),
      ),
    );
  }
}
