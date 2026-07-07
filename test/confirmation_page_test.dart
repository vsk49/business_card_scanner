import 'package:business_card_scanner/models/contact.dart';
import 'package:business_card_scanner/pages/confirmation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('allows editing extracted contact fields before confirming', (
    WidgetTester tester,
  ) async {
    Contact? confirmedContact;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConfirmationPage(
            contactInfo: const Contact(
              name: 'Jane Smith',
              company: 'Acme Corp',
              email: 'jane@example.com',
              phone: '+1 555-0100',
            ),
            onConfirm: (contact) => confirmedContact = contact,
            onTryAgain: () {},
          ),
        ),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Name'),
      'Janet Smith',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Phone'),
      '+1 555-9999',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Email'),
      'janet@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Company'),
      'Acme Global',
    );
    await tester.tap(find.text('Confirm'));

    expect(confirmedContact?.name, 'Janet Smith');
    expect(confirmedContact?.phone, '+1 555-9999');
    expect(confirmedContact?.email, 'janet@example.com');
    expect(confirmedContact?.company, 'Acme Global');
  });
}
