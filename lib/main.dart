import 'package:flutter/material.dart';
import 'package:business_card_scanner/pages/home_page.dart';

void main() {
	runApp(const BusinessCardScannerApp());
}

class BusinessCardScannerApp extends StatelessWidget {
	const BusinessCardScannerApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Business Card Scanner App',
			theme: ThemeData(
        		useMaterial3: true,
        		colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      		),
      		home: const HomePage(), // Sets the initial screen
		);
	}
}