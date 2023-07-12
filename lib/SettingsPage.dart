import 'package:dio/dio.dart';
import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';
import 'net/MyApi.dart';
import 'package:flash/flash.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedMode = 'Paid';

  late MyApi myApi;
  late TextEditingController _textFieldController;
  var content = '正在测试连接，请稍后点击';

  @override
  void initState() {
    super.initState();
    // 在初始化时创建 MyApi 实例
    myApi = MyApi(Dio());
    _textFieldController = TextEditingController();
  }
  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  Future<void> _testConnection(String url) async {
    try {
      Response response = await myApi.testSDConnection(url);
      content = '连接成功';
    } catch (error) {
      content = '连接失败，错误是$error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textFieldController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '请输入sd的地址，一般要有端口号',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                    onPressed: () {
                      _testConnection(_textFieldController.text);
                      context.showFlash(
                        barrierColor: Colors.black54,
                        barrierDismissible: true,
                        builder: (context, controller) => FadeTransition(
                          opacity: controller.controller,
                          child: AlertDialog(
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16)),
                              side: BorderSide(),
                            ),
                            contentPadding: const EdgeInsets.only(
                                left: 24.0,
                                top: 16.0,
                                right: 24.0,
                                bottom: 16.0),
                            title: const Text('测试结果'),
                            content: Text(content),
                            actions: [
                              TextButton(
                                onPressed: controller.dismiss,
                                child: const Text('Ok'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: const Text('点击测试'))
              ]),
              Row(
                children: <Widget>[
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('免费模式'),
                      value: 'Free',
                      groupValue: _selectedMode,
                      onChanged: (value) {
                        setState(() {
                          _selectedMode = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('付费模式'),
                      value: 'Paid',
                      groupValue: _selectedMode,
                      onChanged: (value) {
                        setState(() {
                          _selectedMode = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ]),
      ),
    );
  }
}
