import 'package:flutter/material.dart';
import 'package:mapmyindia_gl/mapmyindia_gl.dart';
import 'package:location/location.dart';

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
  late MapmyIndiaMapController controller;
  LatLng locVal = LatLng(25.321684, 82.987289);
  double zoomVal = 1.0;
  bool x = true;

  @override
  void initState() {
    MapmyIndiaAccountManager.setMapSDKKey(
        "43043434-6de2-4202-bc22-697131af5fd2");
    MapmyIndiaAccountManager.setRestAPIKey("5c66fc4b5ccc180db4cadffb26728a9b");
    MapmyIndiaAccountManager.setAtlasClientId(
        "33OkryzDZsK9DTdogCoMiK7PumCEe4OkT32p2QG3R9oVkjqdy8tx74g_qqpUhrIygeu-xUrr0QLdUx-dhig2YWYWwT8PXV2P");
    MapmyIndiaAccountManager.setAtlasClientSecret(
        "lrFxI-iSEg_MpqKVdNsjdZ-rI7JGWXueQ2pTPjYZ0iEo1-0_7Avrd4WYYuBwif82sDYHa8u7XmTR9h4wZexZ6Rq_9N8D1iPD1K8AdCe6QoU=");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        MapmyIndiaMap(
          initialCameraPosition: CameraPosition(
            target: locVal,
            zoom: zoomVal,
          ),
          onMapCreated: (map) => {
            controller = map,
          },
        ),
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
                      setState(() {
                        x = false;
                      });

                      Location location = Location();

                      var _permissionGranted = await location.hasPermission();
                      if (_permissionGranted == PermissionStatus.denied) {
                        _permissionGranted = await location.requestPermission();
                        if (_permissionGranted != PermissionStatus.granted) {
                          setState(() {
                            x = true;
                          });
                          return;
                        }
                      }

                      LocationData loc = await location.getLocation();
                      LatLng locMap = LatLng(loc.latitude!, loc.longitude!);
                      if (locMap != locVal) {
                        Symbol symbol = await controller
                            .addSymbol(SymbolOptions(geometry: locMap));
                      }
                      setState(() {
                        locVal = locMap;
                        zoomVal = 14.0;
                        controller.moveCamera(
                            CameraUpdate.newLatLngZoom(locMap, 14.0));
                        x = true;
                      });
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
                    onPressed: () {}, child: Center(child: Text('123'))),
              )
            ],
          ),
        ),
        FutureBuilder(
          builder: ((BuildContext context, AsyncSnapshot snapshot) {
            List<Widget> kid = [];
            if (!x) {
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
          }),
        )
      ],
    );
  }
}
