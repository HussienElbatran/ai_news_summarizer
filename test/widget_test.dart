import 'package:flutter_test/flutter_test.dart';
import 'package:ai_news_summarizer/main.dart';

void main() {
  testWidgets('App initializes without errors', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    expect(find.byType(MyApp), findsOneWidget);
  });
}
