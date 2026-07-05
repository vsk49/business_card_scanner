import 'package:flutter/material.dart';
import 'package:business_card_scanner/pages/camera_page.dart';

class HomePage extends StatefulWidget {
	const HomePage({super.key});

	@override
  	State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
	@override
  	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Home')),
			body: Center(child: Text('Want a faster way to save business contacts? Here you are!')),
			backgroundColor: Colors.lightBlue.shade200,
			floatingActionButton: FloatingActionButton(
				onPressed: () {
    				Navigator.of(context).push(
      					MaterialPageRoute(builder: (context) => const CameraPage()),
    				);
  				},
				tooltip: 'Open camera',
				child: const Icon(Icons.camera),
			),
			floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
		);
  	}
}