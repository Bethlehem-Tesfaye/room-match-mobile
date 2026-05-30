import 'package:flutter_test/flutter_test.dart';
import 'package:room_match/main.dart';

void main() {
  testWidgets('App loads login or home', (WidgetTester tester) async {
    await tester.pumpWidget(const RoomMatchApp());
    await tester.pump();
    expect(find.text('RoomMatch'), findsWidgets);
  });
}
