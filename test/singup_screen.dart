import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:medrec/view/singup_screen.dart';

void main() {
  testWidgets('Sign Up form test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: SignupScreen()));

    // Find the name, email, and password TextFields
    final nameField = find.byType(TextField).at(0);
    final emailField = find.byType(TextField).at(1);
    final passwordField = find.byType(TextField).at(2);

    // Enter text into the TextFields
    await tester.enterText(nameField, 'John Doe');
    await tester.enterText(emailField, 'john@example.com');
    await tester.enterText(passwordField, '123456');

    // Press the Sign Up button
    final signUpButton = find.text('Sign up');
    await tester.tap(signUpButton);
    await tester.pump();

    // Add assertions to ensure the signup is successful
    expect(find.text('Error'), findsNothing);
  });
}
