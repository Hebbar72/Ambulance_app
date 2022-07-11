import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key, required this.preferences});
  SharedPreferences preferences;
  List<String> settingsList = [
    "Name",
    "Phone Number",
    "Email ID",
    "Recipients"
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white60,
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text('Settings'),
          leading: BackButton(
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
              children: settingsList
                  .map(
                    (element) => Padding(
                        padding: EdgeInsets.all(5),
                        child: SizedBox(
                            height: 100,
                            child: DecoratedBox(
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4))),
                                child: Card(
                                  shape: const RoundedRectangleBorder(
                                      side: BorderSide(
                                          width: 0, color: Colors.white)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(children: [
                                      Row(children: [
                                        Text(element,
                                            style: const TextStyle(
                                              fontSize: 20,
                                            )),
                                      ]),
                                      TextField(
                                        onSubmitted: (value) async {
                                          await preferences.setString(
                                              element, value);

                                          print(preferences.getString(element));
                                        },
                                        decoration: InputDecoration(
                                          hintText: preferences
                                                  .containsKey(element)
                                              ? preferences.getString(element)
                                              : "Enter text here",
                                        ),
                                      )
                                    ]),
                                  ),
                                )))),
                  )
                  .toList()),
        ));
  }
}
