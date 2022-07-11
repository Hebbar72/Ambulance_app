import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mapmyindia_gl/mapmyindia_gl.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'polyline.dart';
import 'settings.dart';
import 'package:flutter_sms/flutter_sms.dart';

Future<SharedPreferences> loadPreferences() {
  Future<SharedPreferences> temp;
  temp = SharedPreferences.getInstance();
  return temp;
}

class MapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('title'),
        actions: [
          ElevatedButton(
              onPressed: () {
                loadPreferences().then((value) async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SettingsPage(preferences: value)));
                });
              },
              child: Icon(Icons.settings),
              style: ButtonStyle(elevation: MaterialStateProperty.all(0))),
        ],
      ),
      body: UserInterface(),
    );
  }
}

class UserInterface extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return InterfaceState();
  }
}

class InterfaceState extends State<UserInterface> {
  late SharedPreferences settings;
  Location location = Location();
  late String name;
  late String address;
  late Future<LocationData> loc;
  late MapmyIndiaMapController controller;
  late LatLng locVal;
  late double zoomVal;
  late Symbol start;
  final String keyVal = 'Hospital';
  int start_set = 0;
  late Symbol stop;
  int stop_set = 0;
  List<NearbyResult> result = [];
  late List<DirectionsRoute> paths;
  late List<LatLng> coordVal;
  late Line route;
  List<SymbolOptions> symbols = [];
  List<String> settingList = ['Name', 'Phone number', 'Email ID', 'Recipients'];

  Future<bool> getPermission() async {
    var permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
    }
    if (permissionGranted != PermissionStatus.granted) {
      return false;
    }
    return true;
  }

  void getLocation() async {
    bool temp = await getPermission();
    if (temp) {
      setState(() {
        loc = location.getLocation();
      });
    }
  }

  nearby() async {
    setState(() {
      result = [];
    });
    try {
      var nearbyVal = MapmyIndiaNearby(
        keyword: keyVal,
        location: locVal,
        sortBy: 'dist:asc',
        radius: 10000,
      );
      var nearbyResponse = await nearbyVal.callNearby();
      setState(() {
        result = nearbyResponse!.suggestedLocations!;
        address = result[0].placeName!;
        name = result[0].placeAddress!;
      });
    } catch (e) {
      if (e is PlatformException) {
        Fluttertoast.showToast(msg: '${e.code} --- ${e.message}');
      }
    }
  }

  shortestRoute() async {
    try {
      var direction = MapmyIndiaDirection(
        origin: locVal,
        alternatives: true,
        destinationELoc: result[0].eLoc,
      );
      var sol = await direction.callDirection();
      setState(() {
        paths = sol!.routes!;
      });
    } catch (e) {
      if (e is PlatformException) {
        Fluttertoast.showToast(msg: '${e.code} --- ${e.message}');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadPreferences().then((value) {
      setState(() {
        settings = value;
      });
    });
    getLocation();

    MapmyIndiaAccountManager.setMapSDKKey(
        "1cf49542-af5c-40e9-88fc-e4e5261759ab");
    MapmyIndiaAccountManager.setRestAPIKey("5c66fc4b5ccc180db4cadffb26728a9b");
    MapmyIndiaAccountManager.setAtlasClientId(
        "33OkryzDZsK9DTdogCoMiK7PumCEe4OkT32p2QG3R9oVkjqdy8tx74g_qqpUhrIygeu-xUrr0QLdUx-dhig2YWYWwT8PXV2P");
    MapmyIndiaAccountManager.setAtlasClientSecret(
        "lrFxI-iSEg_MpqKVdNsjdZ-rI7JGWXueQ2pTPjYZ0iEo1-0_7Avrd4WYYuBwif82sDYHa8u7XmTR9h4wZexZ6Rq_9N8D1iPD1K8AdCe6QoU=");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loc,
        builder: (BuildContext context, AsyncSnapshot<LocationData> snapshot) {
          List<Widget> kid = [];
          if (snapshot.hasData) {
            locVal =
                LatLng(snapshot.data!.latitude!, snapshot.data!.longitude!);

            zoomVal = 10.0;

            kid.add(
              MapmyIndiaMap(
                initialCameraPosition: CameraPosition(
                  target: locVal,
                  zoom: zoomVal,
                ),
                onMapCreated: (map) => {
                  controller = map,
                },
              ),
            );
            kid.add(
              Container(
                color: const Color.fromARGB(0, 1, 1, 1),
                width: 50,
                height: 100,
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: ElevatedButton(
                          onPressed: () async {
                            await controller.clearSymbols();
                            if (start_set == 0) {
                              setState(() {
                                symbols = [
                                  SymbolOptions(
                                      geometry: locVal,
                                      textField: "You're Here")
                                ];
                              });

                              await controller.addSymbols(symbols);
                            }
                          },
                          child: Icon(Icons.gps_fixed_sharp, size: 30),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.blue,
                              padding: EdgeInsets.all(5),
                              shadowColor: Color.fromARGB(100, 0, 0, 0))),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: ElevatedButton(
                          onPressed: () async {
                            /*await nearby();
                            print(result[0].eLoc);
                            await shortestRoute();
                            Polyline polyline = Polyline.Decode(
                                encodedString: paths[0].geometry, precision: 6);
                            List<LatLng> coords = [];
                            for (var x in polyline.decodedCoords!) {
                              coords.add(LatLng(x[0], x[1]));
                            }
                            print(coords);
                            print(coords[0].latitude);

                            List<SymbolOptions> symbolList = [];
                            symbolList.add(SymbolOptions(
                                geometry: locVal, textField: 'Source'));
                            symbolList.add(SymbolOptions(
                                geometry: coords[coords.length - 1],
                                textField: 'Destination'));
                            setState(() {
                              coordVal = coords;
                              symbols = symbolList;
                            });
                            controller.clearSymbols();
                            await controller.addSymbols(symbols);
                            controller.clearLines();
                            await controller.addLine(LineOptions(
                                geometry: coords,
                                lineColor: 'orange',
                                lineWidth: 5));
                                */
                            settings = await SharedPreferences.getInstance();
                            bool val = false;
                            for (String x in settings.getKeys()) {
                              val = val || settings.getString(x) == " ";
                            }

                            if (val) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 0, sigmaY: 0),
                                        child: AlertDialog(
                                          title: Center(
                                              child:
                                                  Text("Configure Settings!!")),
                                          backgroundColor: Colors.white,
                                          content: Text(
                                              "Please configure all ur settings"),
                                          actionsAlignment:
                                              MainAxisAlignment.center,
                                          actions: [
                                            SizedBox(
                                              height: 50,
                                              width: 100,
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('back')),
                                            ),
                                            SizedBox(
                                              height: 50,
                                              width: 100,
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                SettingsPage(
                                                                    preferences:
                                                                        settings)));
                                                  },
                                                  child: Text('settings')),
                                            )
                                          ],
                                        ));
                                  });
                            } else {
                              String message =
                                  "Alert!!!" + settings.getString("Name")!;
                              String send_result = await sendSMS(
                                  message: message,
                                  recipients: [
                                    settings.getString("Recipients")!
                                  ]).catchError((err) {
                                print(err);
                              });
                              print(send_result);
                            }
                            print('done');
                          },
                          child: Center(child: Text('123'))),
                    ),
                  ],
                ),
              ),
            );

            return Stack(
              alignment: Alignment.bottomRight,
              children: kid,
            );
          } else {
            kid.add(Center(
                child: Container(
              alignment: Alignment.center,
              width: 50,
              height: 50,
              child: CircularProgressIndicator(),
            )));
          }
          return Row(
            children: kid,
            mainAxisAlignment: MainAxisAlignment.center,
          );
        });
  }
}
