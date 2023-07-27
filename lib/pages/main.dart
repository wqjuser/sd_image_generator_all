import 'dart:io';

import 'package:flash/flash_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sd_image_generator_all/pages/article_generator_view.dart';
import 'package:sd_image_generator_all/pages/random_generator_view.dart';
import 'package:window_manager/window_manager.dart';
import '../config/config.dart';
import 'settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 必须加上这一行。
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 720),
    minimumSize: Size(960, 540),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setPreventClose(true);
  });
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

class _MyHomePageState extends State<MyHomePage> with WindowListener {
  int _selectedIndex = 0;

  void createDirectory() async {
    Map<String, String> envVars = Platform.environment;

    const dirName = 'ImageGenerator';
    final path = Platform.isWindows ? 'C:/Users/Administrator/Pictures/$dirName' : '/Users/${envVars['USER']}/Pictures/$dirName';

    final directory = Directory(path);

    if (await directory.exists()) {
      if (kDebugMode) {
        print('目录 $path 已存在');
      }
    } else {
      await directory.create(recursive: true).then((Directory directory) {
        if (kDebugMode) {
          print('目录 ${directory.path}被创建');
        }
      });
    }
  }

  Future<void> generateDefaultValues() async {
    Map<String, dynamic> settings = {
      'is_first_use': false,
      'default_model': '', //默认模型，为空时采用当前sd选择的模型
      'steps': 20, //默认迭代步数
      'width': 512,
      'height': 512,
      'default_positive_prompts_type': 1,
      'is_compiled_positive_prompts': false,
      'compiled_positive_prompts_type': '',
      'use_self_positive_prompts': false,
      'self_positive_prompts': '',
      'use_self_negative_prompts': false,
      'self_negative_prompts': '',
      'Sampler': 'Euler a',
      'restore_face': false,
      'hires_fix': false,
      'hires_fix_sampler': 'Latent',
      'hires_fix_steps': 0,
      'hires_fix_amplitude': 0.2,
      'hires_fix_multiple': 2.0,
      'loras': '',
      'chat_api_key': '',
      'chat_account': '',
      'chat_password': '',
      'baidu_trans_app_id': '',
      'baidu_trans_app_key': '',
      'deepl_api_key': '',
      'baidu_voice_api_key': '',
      'baidu_voice_secret_key': '',
      'baidu_voice_app_id': '',
      'ali_voice_api_key': '',
      'ali_voice_secret_key': '',
      'ali_voice_app_id': '',
      'huawei_voice_ak': '',
      'huawei_voice_sk': '',
      'azure_voice_speech_key': '',
      'jy_draft_save_path': '',
    };
    await Config.saveSettings(settings);
  }

  Future<void> generateSDDefaultValues() async {
    Map<String, dynamic> settings = {
      'is_first_use': false,
      'default_model': '', //默认模型，为空时采用当前sd选择的模型
      'steps': 20, //默认迭代步数
      'width': 512,
      'height': 512,
      'default_positive_prompts_type': 1,
      'is_compiled_positive_prompts': false,
      'compiled_positive_prompts_type': '',
      'use_self_positive_prompts': false,
      'self_positive_prompts': '',
      'use_self_negative_prompts': false,
      'self_negative_prompts': '',
      'Sampler': 'Euler a',
      'restore_face': false,
      'hires_fix': false,
      'hires_fix_sampler': 'Latent',
      'hires_fix_steps': 0,
      'hires_fix_amplitude': 0.2,
      'hires_fix_multiple': 2.0,
      'loras': '',
    };
    await Config.saveSettings(settings);
  }

  Future<void> loadSettings() async {
    Map<String, dynamic> settings = await Config.loadSettings();
    bool? isFirstUse = settings['is_first_use'];
    if (isFirstUse == null) {
      generateDefaultValues(); //首次使用且免费模式创建默认参数
      createDirectory(); //创建默认图片保存的文件夹
    }
  }

  @override
  void initState() {
    loadSettings();
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      if (context.mounted) {
        context.showFlash(
          barrierColor: Colors.black54,
          barrierDismissible: true,
          builder: (context, controller) => FadeTransition(
            opacity: controller.controller,
            child: AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                side: BorderSide(),
              ),
              contentPadding: const EdgeInsets.only(left: 24.0, top: 16.0, right: 24.0, bottom: 16.0),
              title: const Text('退出应用'),
              content: const Text("你确认退出应用吗? 需要保存此次对SD的相关设置吗? "),
              actions: [
                TextButton(
                  onPressed: () async {
                    controller.dismiss();
                  },
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () async {
                    controller.dismiss();
                    Navigator.of(context).pop();
                    await windowManager.destroy();
                  },
                  child: const Text('保存并退出'),
                ),
                TextButton(
                  onPressed: () async {
                    controller.dismiss();
                    Navigator.of(context).pop();
                    await generateSDDefaultValues();
                    await windowManager.destroy();
                  },
                  child: const Text('不保存并退出'),
                ),
              ],
            ),
          ),
        );
      }
    }
    super.onWindowClose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // 关闭抽屉
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
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              title: const Text('随机图片生成器'),
              onTap: () => _onItemTapped(1),
            ),
          ],
        ),
      ),
      body: _buildBodyContent(),
    );
  }

  Widget _buildBodyContent() {
    switch (_selectedIndex) {
      case 0:
        return const ArticleGeneratorView();
      case 1:
        return const RandomGeneratorView();
      default:
        return Container(); // 返回一个空的容器作为默认视图
    }
  }
}
