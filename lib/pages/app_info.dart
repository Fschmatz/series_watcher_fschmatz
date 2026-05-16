import 'package:flutter/material.dart';

import '../../util/utils_functions.dart';
import '../util/app_constants.dart';

class AppInfo extends StatelessWidget {
  const AppInfo({super.key});

  @override
  Widget build(BuildContext context) {
    Color themeColorApp = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text("App info")),
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 55,
            backgroundColor: Colors.deepOrangeAccent,
            child: CircleAvatar(radius: 50, backgroundImage: AssetImage('assets/avatar.jpg')),
          ),
          const SizedBox(height: 15),
          Center(
            child: Text(
              "${AppConstants.appName} ${AppConstants.appVersion}",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: themeColorApp),
            ),
          ),
          const SizedBox(height: 15),
          ListTile(
            title: Text(
              "Dev",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: themeColorApp),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("Application created using Flutter and the Dart language, used for testing and learning."),
          ),
          ListTile(
            title: Text(
              "Source Code",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: themeColorApp),
            ),
          ),
          ListTile(
            onTap: () {
              UtilsFunctions.openGithubRepository();
            },
            leading: const Icon(Icons.open_in_new_outlined),
            title: const Text(
              "View on GitHub",
              style: TextStyle(decoration: TextDecoration.underline, decorationColor: Colors.blue, color: Colors.blue),
            ),
          ),
          /* ListTile(
            title: Text("Quote", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: themeColorApp)),
          ),
          const ListTile(
            leading: Icon(Icons.messenger_outline),
            title: Text(
              "A strange art – music – the most poetic and precise of all the arts, vague as a dream and precise as algebra.",
            ),
          ),*/
        ],
      ),
    );
  }
}
