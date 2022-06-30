import 'package:flutter/material.dart';
import 'package:mapmyindia_gl/mapmyindia_gl.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'cant be bothered to come up with a title',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('who cares'),
        ),
        body: UserInterface(),
      ),
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
  Location location = Location();
  late Future<LocationData> loc;
  late MapmyIndiaMapController controller;
  late LatLng locVal;
  late double zoomVal;
  late Symbol start;
  final String keyVal = 'hospital';
  int start_set = 0;
  late Symbol stop;
  int stop_set = 0;
  late Route path;
  List<NearbyResult> result = [];

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
      );
      var nearbyResponse = await nearbyVal.callNearby();
      setState(() {
        result = nearbyResponse!.suggestedLocations!;
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
    getLocation();

    MapmyIndiaAccountManager.setMapSDKKey(
        "61c10a2f-2b32-40a0-9687-5061d5d3906b");
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
            zoomVal = 14.0;
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
                          onPressed: () {
                            if (start_set == 0) {
                              setState(() async {
                                start_set = 1;
                                start = await controller
                                    .addSymbol(SymbolOptions(geometry: locVal));
                              });
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
                            nearby();
                            print(result.length);
                          },
                          child: Center(child: Text('123'))),
                    )
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
