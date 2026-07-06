import 'package:business_card_scanner/models/contact.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
	test('fromOcrText extracts common business card fields', () {
		final contact = Contact.fromOcrText('''
			Jane Smith
			Acme Corp
			Mobile: +1 (555) 012-3456
			jane.smith@example.com
			www.example.com
		''');

		expect(contact.name, 'Jane Smith');
		expect(contact.company, 'Acme Corp');
		expect(contact.phone, '+1 (555) 012-3456');
		expect(contact.email, 'jane.smith@example.com');
	});
}
