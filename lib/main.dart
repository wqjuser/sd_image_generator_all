import 'dart:ui';

import 'package:flutter/material.dart';
import 'SettingsPage.dart';

// void main() {
//   runApp(const MyApp());
// }
Future<void> main() async {

  //如果size是0，则设置回调，在回调中runApp
  if(window.physicalSize.isEmpty){
    print("window size is zero");
    window.onMetricsChanged = (){
      //在回调中，size仍然有可能是0
      if(!window.physicalSize.isEmpty){
        window.onMetricsChanged = null;
        print("window onMetricsChanged,run app");
        runMyApp();
      }
    };
  } else{
    //如果size非0，则直接runApp
    print("window load success,run app");
    runMyApp();
  }
}

void runMyApp() async{

  print("window:  ${window.physicalSize.width}  ${window.physicalSize.height}");
  //需确保加载完成，才runApp
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SDImageGenerator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'SDImageGenerator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _setState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        // Populate the Drawer in the next step.
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('用SD来体验AIGC的魅力'),
            ),
            ListTile(
              title: const Text('文章图片生成器'),
              onTap: () {
                // Update the state of the app.
                // Then close the drawer.
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('随机图片生成器'),
              onTap: () {
                // Update the state of the app.
                // Then close the drawer.
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
