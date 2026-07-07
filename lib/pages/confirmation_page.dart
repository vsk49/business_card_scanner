import 'package:flutter/material.dart';
import 'package:business_card_scanner/models/contact.dart';

class ConfirmationPage extends StatefulWidget {
  final Contact contactInfo;
  final ValueChanged<Contact> onConfirm;
  final VoidCallback onTryAgain;

  const ConfirmationPage({
    super.key,
    required this.contactInfo,
    required this.onConfirm,
    required this.onTryAgain,
  });

  @override
  State<ConfirmationPage> createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _companyController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contactInfo.name);
    _phoneController = TextEditingController(text: widget.contactInfo.phone);
    _emailController = TextEditingController(text: widget.contactInfo.email);
    _companyController = TextEditingController(text: widget.contactInfo.company);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Contact get _editedContact {
    return Contact(
      name: _valueOrUnknown(_nameController.text),
      company: _valueOrUnknown(_companyController.text),
      email: _valueOrUnknown(_emailController.text),
      phone: _valueOrUnknown(_phoneController.text),
    );
  }

  String _valueOrUnknown(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? 'Unknown' : trimmed;
  }

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
          _infoField('Name', _nameController),
          _infoField('Phone', _phoneController),
          _infoField('Email', _emailController),
          _infoField('Company', _companyController),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onTryAgain,
          child: const Text('Try again'),
        ),
        ElevatedButton(
          onPressed: () => widget.onConfirm(_editedContact),
          child: const Text('Confirm'),
        ),
      ],
    );
  }

  Widget _infoField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: _keyboardTypeFor(label),
        textCapitalization: label == 'Email'
            ? TextCapitalization.none
            : TextCapitalization.words,
      ),
    );
  }

  TextInputType _keyboardTypeFor(String label) {
    switch (label) {
      case 'Email':
        return TextInputType.emailAddress;
      case 'Phone':
        return TextInputType.phone;
      default:
        return TextInputType.text;
    }
  }
}
