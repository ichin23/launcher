import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Launcher',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController searchApp = TextEditingController();
  List apps = [];
  List todosApps = [];
  Stream<ApplicationEvent> appsListen = DeviceApps.listenToAppsChanges();

  Future<void> getApps() async {
    List customApps = await DeviceApps.getInstalledApplications(
        includeAppIcons: true, onlyAppsWithLaunchIntent: true);
    customApps.sort((a, b) => a.appName.compareTo(b.appName));
    setState(() {
      apps = customApps;
      todosApps = customApps;
    });
    //print(apps);
  }

  Future<void> listenApps() async {
    Stream<ApplicationEvent> novosApps = DeviceApps.listenToAppsChanges();

    print(novosApps);
  }

  @override
  void initState() {
    super.initState();
    listenApps();
    getApps();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.grey[900],
              elevation: 0,
              title: Container(
                height: 40,
                child: TextField(
                  decoration: InputDecoration(
                      labelText: "Search...",
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(80),
                          borderSide: BorderSide(
                              color: Colors.deepPurple,
                              style: BorderStyle.solid)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                              color: Colors.deepPurple,
                              style: BorderStyle.solid)),
                      labelStyle: TextStyle(color: Colors.white),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                      suffix: IconButton(
                        icon: Icon(Icons.delete, color: Colors.white),
                        onPressed: () {
                          print(todosApps);
                          setState(() {
                            searchApp.text = '';
                            apps = todosApps;
                          });
                        },
                      )),
                  style: TextStyle(color: Colors.white),
                  enableSuggestions: true,
                  controller: searchApp,
                  showCursor: true,
                  onChanged: (text) {
                    print(text);
                    if (text != '') {
                      List newApps = todosApps.where((app) {
                        final String appTitle =
                            app.appName.toString().toLowerCase();
                        return appTitle.contains(text.toLowerCase());
                      }).toList();
                      setState(() {
                        this.apps = newApps;
                      });
                      print(apps);
                    } else if (text == null || text == '') {
                      setState(() {
                        this.apps = todosApps;
                      });
                    }
                  },
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  return ListTile(
                      onTap: () {
                        print(apps[i]);
                        DeviceApps.openApp(apps[i].packageName);
                      },
                      onLongPress: () {
                        DeviceApps.openAppSettings(apps[i].packageName);
                      },
                      title: Text(
                        apps[i].appName,
                        style: TextStyle(color: Colors.white),
                      ),
                      leading: Image.memory(apps[i].icon));
                },
                childCount: apps.length,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple[900],
        child: Icon(Icons.refresh),
        onPressed: () async {
          getApps();
        },
      ),
    );
  }
}
