import 'package:flutter/material.dart';

class ConfirmationPage extends StatelessWidget {
	final Map<String, String> contactInfo;
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
					_infoRow('Name', contactInfo['name'] ?? 'Unknown'),
					_infoRow('Phone', contactInfo['phone'] ?? 'Unknown'),
					_infoRow('Email', contactInfo['email'] ?? 'Unknown'),
					_infoRow('Company', contactInfo['company'] ?? 'Unknown'),
				],
			),
			actions: [
				TextButton(
					onPressed: onTryAgain,
					child: const Text('Try again'),
				),
				ElevatedButton(
					onPressed: onConfirm,
					child: const Text('Confirm'),
				),
			],
		);
	}

	Widget _infoRow(String label, String value) {
		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 4),
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					SizedBox(
						width: 70,
						child: Text('$label:'),
					),
					Expanded(child: Text(value)),
				],
			),
		);
	}
}