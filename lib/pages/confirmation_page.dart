import 'package:flutter/material.dart';
import 'package:business_card_scanner/models/contact.dart';

class ConfirmationPage extends StatelessWidget {
	final Contact contactInfo;
	final VoidCallback onConfirm;
	final VoidCallback onTryAgain;

	const ConfirmationPage({
		super.key,
		required this.contactInfo,
		required this.onConfirm,
		required this.onTryAgain,
	});

	@override
	Widget build(BuildContext context) {
		return AlertDialog(
			title: const Text('Confirm extracted contact'),
			content: Column(
				mainAxisSize: MainAxisSize.min,
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					const Text('We found this information:'),
					const SizedBox(height: 12),
					_infoRow('Name', contactInfo.name),
					_infoRow('Phone', contactInfo.phone),
					_infoRow('Email', contactInfo.email),
					_infoRow('Company', contactInfo.company),
				],
			),
			actions: [
				TextButton(onPressed: onTryAgain, child: const Text('Try again')),
				ElevatedButton(onPressed: onConfirm, child: const Text('Confirm')),
			],
		);
	}

	Widget _infoRow(String label, String value) {
		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 4),
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					SizedBox(width: 70, child: Text('$label:')),
					Expanded(child: Text(value)),
				],
			),
		);
	}
}
