import 'package:flutter/material.dart';

import '../../config/app_localizations.dart';

class CompanyInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('company_info')),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/logo.png',
                height: 100,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'JWPOS OFFLINE',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                localizations.translate('version') + ' 1.0',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Divider(height: 30),
            _buildInfoRow(
              Icons.business,
              localizations.translate('companyName'),
            ),
            _buildInfoRow(
              Icons.calendar_today,
              localizations.translate('companyEstablished'),
            ),
            _buildInfoRow(
              Icons.web,
              localizations.translate('websiteLink'),
            ),
            _buildPhoneRow(context, '849-883-5985'),
            Divider(height: 30),
            Text(
              localizations.translate('system_description'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              localizations.translate('system_details'),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, [String content = '']) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey),
          SizedBox(width: 10),
          Text(
            '$title ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (content.isNotEmpty)
            Expanded(
              child: Text(
                content,
                style: TextStyle(fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhoneRow(BuildContext context, String phoneNumber) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Image.asset(
            'assets/whats.png',
            height: 30,
            width: 30,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              phoneNumber,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),
            ),
          ),
        ],
      ),
    );
  }
}
