import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.emoji_events, color: Colors.yellow),
                  title: const Text(
                    "More of App",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  trailing: GestureDetector(
                    onTap: () {
                      // Just dismiss the sheet without navigating back
                      Navigator.of(context).pop();
                    },
                    child: const Icon(Icons.close, size: 28, color: Colors.black),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      _buildListTile(Icons.spa, "Ayurveda"),
                      _buildListTile(Icons.star, "How we Score"),
                      _buildListTile(Icons.help, "FAQ's"),
                      _buildListTile(Icons.rate_review, "Review's"),
                      _buildListTile(Icons.info, "About Us"),
                      _buildListTile(Icons.contact_mail, "Contact us"),
                      _buildListTile(Icons.policy, "Terms and Conditions"),
                      _buildListTile(Icons.share, "Share Us"),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white),
      onTap: () {
        // Handle the tap action here
      },
    );
  }
}