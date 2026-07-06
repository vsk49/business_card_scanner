class Contact {
  final String name;
  final String company;
  final String email;
  final String phone;

  const Contact({
    required this.name,
    required this.company,
    required this.email,
    required this.phone,
  });

  Map<String, String> toMap() {
    return {'name': name, 'company': company, 'email': email, 'phone': phone};
  }

  factory Contact.fromOcrText(String text) {
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    String name = 'Unknown';
    String company = 'Unknown';
    String email = 'Unknown';
    String phone = 'Unknown';

    final emailRegex = RegExp(
      r'[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}',
      caseSensitive: false,
    );
    final phoneRegex = RegExp(r'(\+?\d[\d\s().-]{6,}\d)');
    final ignoredLabels = RegExp(
      r'\b(email|e-mail|phone|mobile|tel|fax|www|http)\b',
      caseSensitive: false,
    );

    for (final line in lines) {
      final emailMatch = emailRegex.firstMatch(line);
      if (email == 'Unknown' && emailMatch != null) {
        email = emailMatch.group(0)!;
        continue;
      }

      final phoneMatch = phoneRegex.firstMatch(line);
      if (phone == 'Unknown' && phoneMatch != null) {
        phone = phoneMatch.group(0)!.trim();
        continue;
      }

      if (ignoredLabels.hasMatch(line)) {
        continue;
      }

      if (name == 'Unknown') {
        name = line;
      } else if (company == 'Unknown') {
        company = line;
      }
    }

    return Contact(name: name, company: company, email: email, phone: phone);
  }
}
