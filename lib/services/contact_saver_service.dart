import 'package:business_card_scanner/models/contact.dart' as app;
import 'package:flutter_contacts/flutter_contacts.dart' as device;

class ContactSaverService {
  Future<void> save(app.Contact contact) async {
    final permissionStatus = await device.FlutterContacts.permissions.request(
      device.PermissionType.readWrite,
    );

    if (permissionStatus != device.PermissionStatus.granted) {
      throw const ContactSavePermissionException();
    }

    await device.FlutterContacts.create(_toDeviceContact(contact));
  }

  device.Contact _toDeviceContact(app.Contact contact) {
    return device.Contact(
      name: device.Name(first: _nonUnknownValue(contact.name)),
      phones: [
        if (_hasValue(contact.phone))
          device.Phone(
            number: contact.phone,
            label: device.Label(device.PhoneLabel.mobile),
          ),
      ],
      emails: [
        if (_hasValue(contact.email))
          device.Email(
            address: contact.email,
            label: device.Label(device.EmailLabel.work),
          ),
      ],
      organizations: [
        if (_hasValue(contact.company))
          device.Organization(name: contact.company),
      ],
    );
  }

  bool _hasValue(String value) {
    final trimmed = value.trim();
    return trimmed.isNotEmpty && trimmed != 'Unknown';
  }

  String _nonUnknownValue(String value) {
    return _hasValue(value) ? value.trim() : '';
  }
}

class ContactSavePermissionException implements Exception {
  const ContactSavePermissionException();
}
