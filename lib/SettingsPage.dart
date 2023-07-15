import 'package:dio/dio.dart';
import 'package:flash/flash_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'net/MyApi.dart';
import 'config/config.dart';
import 'utils/utils.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedMode = 1; // 修改为 int 类型
  String _sdUrl = '';
  bool _isMixPrompt = false;
  bool _isSelfPositivePrompt = false;
  bool _isSelfNegativePrompt = false;
  bool _isUseFaceStore = false;
  bool _isHiresFix = false;
  String _selectedOption = '1.基本提示(通用)';
  List<String> _loras = ['请先获取可用Lora列表'];
  String _selectedLora = '请先获取可用Lora列表';
  List<String> _models = ['请先获取可用模型列表'];
  String _selectedModel = '请先获取可用模型列表';
  List<String> _vaes = ['请先获取可用vae列表'];
  String _selectedVae = '请先获取可用vae列表';
  List<String> _samplers = ['Euler a'];
  String _selectedSampler = 'Euler a';
  List<String> _upscalers = ['None'];
  String _selectedUpscalers = 'None';
  final List<String> _options = [
    '1.基本提示(通用)',
    '2.基本提示(通用修手)',
    '3.基本提示(增加细节1)',
    '4.基本提示(增加细节2)',
    '5.基本提示(梦幻童话)'
  ];

  late MyApi myApi;
  late TextEditingController _textFieldController;
  late TextEditingController _loraTextFieldController;
  late TextEditingController _hireFix1TextFieldController;
  late TextEditingController _hireFix2TextFieldController;
  late TextEditingController _hireFix3TextFieldController;
  late TextEditingController _samplerTextFieldController;
  late TextEditingController _picWidthTextFieldController;
  late TextEditingController _picHeightTextFieldController;
  var content = '正在测试连接，请稍后点击';

  @override
  void initState() {
    super.initState();
    // 在初始化时创建 MyApi 实例
    myApi = MyApi(Dio());
    _textFieldController = TextEditingController(text: _sdUrl);
    _loraTextFieldController = TextEditingController();
    _hireFix1TextFieldController = TextEditingController(text: '5');
    _hireFix2TextFieldController = TextEditingController(text: '0.5');
    _hireFix3TextFieldController = TextEditingController(text: '2');
    _samplerTextFieldController = TextEditingController(text: '20');
    _picWidthTextFieldController = TextEditingController(text: '512');
    _picHeightTextFieldController = TextEditingController(text: '512');
    loadSettings();
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  Future<void> _testConnection(String url) async {
    try {
      Response response = await myApi.testSDConnection(url);
      if (response.statusCode == 200) {
        content = '连接成功';
      } else {
        content = '连接失败，错误是${response.statusMessage}';
      }
    } catch (error) {
      content = '连接失败，错误是$error';
    }
  }

  Future<void> _getLoras(String url) async {
    try {
      Response response = await myApi.getSDLoras(url);
      if (response.statusCode == 200) {
        _loras.clear();
        for (int i = 0; i < response.data.length; i++) {
          _loras.add(response.data[i]['name']);
        }
      } else {
        if (kDebugMode) {
          print('获取Lora列表失败，错误是${response.statusMessage}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('获取Lora列表失败，错误是$error');
      }
    }
    setState(() {});
    if (_loras.isNotEmpty) {
      _selectedLora = _loras[0];
    }
  }

  Future<void> _getModels(String url) async {
    try {
      Response response = await myApi.getSDModels(url);
      if (response.statusCode == 200) {
        _models.clear();
        for (int i = 0; i < response.data.length; i++) {
          var input = response.data[i]['title'];
          int indexOfBracket = input.indexOf('['); // 查找 "[" 的索引位置
          String result = '';
          if (indexOfBracket != -1) {
            result = input.substring(0, indexOfBracket).trim();
          } else {
            result = input; // 获取 "[" 前面的子字符串，并去除前面的空格
          }
          _models.add(result);
        }
      } else {
        if (kDebugMode) {
          print('获取模型列表失败1，错误是${response.statusMessage}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('获取模型列表失败2，错误是$error');
      }
    }
    setState(() {});
    if (_models.isNotEmpty) {
      _selectedModel = _models[0];
    }
  }

  Future<void> _getVaes(String url) async {
    try {
      Response response = await myApi.getSDVaes(url);
      if (response.statusCode == 200) {
        _vaes.clear();
        for (int i = 0; i < response.data.length; i++) {
          _vaes.add(response.data[i]['model_name']);
        }
      } else {
        if (kDebugMode) {
          print('获取vae列表失败1，错误是${response.statusMessage}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('获取模型vae失败2，错误是$error');
      }
    }
    setState(() {});
    if (_vaes.isNotEmpty) {
      _selectedVae = _vaes[0];
    }
  }

  Future<void> _getSamplers(String url) async {
    try {
      Response response = await myApi.getSDSamplers(url);
      if (response.statusCode == 200) {
        _samplers.clear();
        for (int i = 0; i < response.data.length; i++) {
          _samplers.add(response.data[i]['name']);
        }
      } else {
        if (kDebugMode) {
          print('获取采样器列表失败1，错误是${response.statusMessage}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('获取模型采样器失败2，错误是$error');
      }
    }
    setState(() {});
    if (_samplers.isNotEmpty) {
      _selectedSampler = _samplers[0];
    }
  }

  Future<void> _getUpscalers(String url) async {
    try {
      Response response = await myApi.getSDlLatentUpscaleModes(url);
      if (response.statusCode == 200) {
        _upscalers.clear();
        for (int i = 0; i < response.data.length; i++) {
          _upscalers.add(response.data[i]['name']);
        }
      } else {
        if (kDebugMode) {
          print('获取高清修复算法列表失败1，错误是${response.statusMessage}');
        }
      }
      Response response1 = await myApi.getSDUpscalers(url);
      if (response1.statusCode == 200) {
        for (int i = 0; i < response1.data.length; i++) {
          _upscalers.add(response1.data[i]['name']);
        }
      } else {
        if (kDebugMode) {
          print('获取高清修复算法列表失败3，错误是${response1.statusMessage}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('获取高清修复算法列表失败2，错误是$error');
      }
    }
    setState(() {});
    if (_upscalers.isNotEmpty) {
      _selectedUpscalers = _upscalers[0];
    }
  }

  Future<void> loadSettings() async {
    Map<String, dynamic> settings = await Config.loadSettings();
    int? useMode = settings['useMode']; // 使用 int 或 dynamic 类型
    String? sdUrl = settings['sdUrl'];
    setState(() {
      if (sdUrl != null) {
        _sdUrl = sdUrl;
      }
      if (useMode != null) {
        _selectedMode = useMode;
      }
      _textFieldController = TextEditingController(text: _sdUrl);
      if (_sdUrl != '') {
        _getModels(_sdUrl);
        _getSamplers(_sdUrl);
        _getLoras(_sdUrl);
        _getVaes(_sdUrl);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                  child: ListView(
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
                        onPressed: () async {
                          Map<String, dynamic> settings = {
                            'sdUrl': _textFieldController.text,
                          };
                          await Config.saveSettings(settings);
                          await _testConnection(_textFieldController.text);
                          // ignore: use_build_context_synchronously
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
                        child: const Text('测试连接'))
                  ]),
                  const SizedBox(height: 10),
                  Visibility(
                    visible: false,
                    child: Row(
                      children: <Widget>[
                        const Text('使用模式：'),
                        Expanded(
                          child: RadioListTile<int>(
                            title: const Text('免费'),
                            value: 0,
                            groupValue: _selectedMode,
                            onChanged: (value) async {
                              Map<String, dynamic> settings = {
                                'useMode': value!,
                              };
                              await Config.saveSettings(settings);
                              setState(() {
                                _selectedMode = value;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<int>(
                            title: const Text('付费'),
                            value: 1,
                            groupValue: _selectedMode,
                            onChanged: (value) async {
                              Map<String, dynamic> settings = {
                                'useMode': value!,
                              };
                              await Config.saveSettings(settings);
                              setState(() {
                                _selectedMode = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      const SizedBox(
                          width: 70, // 设置容器的宽度
                          child: Text('可用模型:')),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton(
                          value: _selectedModel,
                          items: _models
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedModel = newValue!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                          width: 200, // 设置容器的宽度
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_textFieldController.text != '') {
                                await _getModels(_textFieldController.text);
                              } else {
                                context.showToast(const Text('请先配置sd地址'));
                              }
                            },
                            child: const Text('获取可用模型列表'),
                          )),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      const SizedBox(
                          width: 70, // 设置容器的宽度
                          child: Text('可用Lora:')),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton(
                          value: _selectedLora, // 设置选中值
                          items: _loras
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              if (_selectedLora != newValue) {
                                _loraTextFieldController.text =
                                    '${_loraTextFieldController.text}<lora:$newValue:1>, ';
                              }
                              _selectedLora = newValue!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                          width: 200, // 设置容器的宽度
                          child: ElevatedButton(
                              onPressed: () async {
                                if (_textFieldController.text != '') {
                                  await _getLoras(_textFieldController.text);
                                } else {
                                  context.showToast(const Text('请先配置sd地址'));
                                }
                              },
                              child: const Text('获取可用Lora列表'))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      const SizedBox(
                          width: 70, // 设置容器的宽度
                          child: Text('可用vae:')),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton(
                          value: _selectedVae,
                          items: _vaes
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedVae = newValue!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                          width: 200, // 设置容器的宽度
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_textFieldController.text != '') {
                                await _getVaes(_textFieldController.text);
                              } else {
                                context.showToast(const Text('请先配置sd地址'));
                              }
                            },
                            child: const Text('获取可用vae列表'),
                          )),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      const Text('默认正面提示词类别:'),
                      const SizedBox(width: 10),
                      DropdownButton(
                        value: _selectedOption, // 设置选中值
                        items: _options
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedOption = newValue!;
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      Row(children: <Widget>[
                        GestureDetector(
                            onTap: () {
                              setState(() {
                                _isMixPrompt = !_isMixPrompt;
                              });
                            },
                            child: Row(
                              children: <Widget>[
                                Checkbox(
                                  value: _isMixPrompt,
                                  onChanged: (bool? newValue) {
                                    setState(() {
                                      _isMixPrompt = newValue ?? false;
                                    });
                                  },
                                ),
                                const SizedBox(width: 2),
                                const Text('组合类别'),
                              ],
                            ))
                      ]),
                      const SizedBox(width: 5),
                      Visibility(
                        visible: _isMixPrompt,
                        child: const Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: '输入组合类别，比如1+2，请勿组合过多种类',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isSelfPositivePrompt = !_isSelfPositivePrompt;
                              });
                            },
                            child: Row(
                              children: <Widget>[
                                Checkbox(
                                  value: _isSelfPositivePrompt,
                                  onChanged: (bool? newValue) {
                                    setState(() {
                                      _isSelfPositivePrompt = newValue ?? false;
                                    });
                                  },
                                ),
                                const SizedBox(width: 2),
                                const Text('自行输入默认正面提示词(勾选后上面的选择将失效)'),
                              ],
                            )),
                      ),
                      Expanded(
                        child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isSelfNegativePrompt = !_isSelfNegativePrompt;
                              });
                            },
                            child: Row(
                              children: <Widget>[
                                Checkbox(
                                  value: _isSelfNegativePrompt,
                                  onChanged: (bool? newValue) {
                                    setState(() {
                                      _isSelfNegativePrompt = newValue ?? false;
                                    });
                                  },
                                ),
                                const SizedBox(width: 2),
                                const Text('自行输入默认负面提示词'),
                              ],
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Visibility(
                          visible: _isSelfPositivePrompt,
                          child: const Expanded(
                              child: TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: '默认正面提示词，影响每一张图片',
                            ),
                          ))),
                      Visibility(
                        visible: _isSelfNegativePrompt & _isSelfPositivePrompt,
                        child: const SizedBox(width: 10),
                      ),
                      Visibility(
                          visible: _isSelfNegativePrompt,
                          child: const Expanded(
                              child: TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: '默认负面提示词，影响每一张图片',
                            ),
                          ))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                          child: TextField(
                              maxLength: null,
                              controller: _loraTextFieldController,
                              keyboardType: TextInputType.multiline,
                              decoration: const InputDecoration(
                                  hintText:
                                      '格式是<lora:lora的名字:lora的权重>,支持多个lora，例如 <lora:fashionGirl_v54:0.5>, <lora:cuteGirlMix4_v10:0.6>',
                                  border: OutlineInputBorder(),
                                  labelText:
                                      '使用Lora，注意此处使用的Lora将影响所有图片，从上方可用Lora的列表中选择'))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      const Text('绘图采样算法:'),
                      const SizedBox(width: 6),
                      DropdownButton(
                        value: _selectedSampler, // 设置选中值
                        items: _samplers
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedSampler = newValue!;
                          });
                        },
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: _samplerTextFieldController,
                          decoration: const InputDecoration(
                            labelText: '绘图迭代步数',
                            hintText: '20',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 200,
                        child: TextField(
                          controller: _picWidthTextFieldController,
                          decoration: const InputDecoration(
                            labelText: '绘图图片宽度(范围是64-2048)',
                            hintText: '512',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 200,
                        child: TextField(
                          controller: _picHeightTextFieldController,
                          decoration: const InputDecoration(
                            labelText: '绘图图片高度(范围64-2048)',
                            hintText: '512',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isUseFaceStore = !_isUseFaceStore;
                          });
                        },
                        child: Row(children: <Widget>[
                          Checkbox(
                            value: _isUseFaceStore,
                            onChanged: (bool? newValue) {
                              setState(() {
                                _isUseFaceStore = newValue ?? false;
                              });
                            },
                          ),
                          const SizedBox(width: 2),
                          const Text('面部修复'),
                        ]),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isHiresFix = !_isHiresFix;
                          });
                        },
                        child: Row(children: <Widget>[
                          Checkbox(
                            value: _isHiresFix,
                            onChanged: (bool? newValue) {
                              setState(() {
                                _isHiresFix = newValue ?? false;
                              });
                              if (_isHiresFix) {
                                _getUpscalers(_textFieldController.text);
                              }
                            },
                          ),
                          const SizedBox(width: 2),
                          const Text('高清修复'),
                        ]),
                      ),
                      const SizedBox(width: 6),
                      Visibility(
                          visible: _isHiresFix,
                          child: Row(children: <Widget>[
                            const Text('高清修复算法:'),
                            const SizedBox(width: 6),
                            DropdownButton(
                              value: _selectedUpscalers, // 设置选中值
                              items: _upscalers.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedUpscalers = newValue!;
                                });
                              },
                            ),
                            const SizedBox(width: 6),
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: _hireFix1TextFieldController,
                                decoration: const InputDecoration(
                                  labelText: '高清迭代步数',
                                  hintText: '5',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: _hireFix2TextFieldController,
                                decoration: const InputDecoration(
                                  labelText: '高清重绘幅度',
                                  hintText: '0.5',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  DecimalTextInputFormatter(
                                      decimalRange: 2,
                                      minValue: 0,
                                      maxValue: 1),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: _hireFix3TextFieldController,
                                decoration: const InputDecoration(
                                  labelText: '高清放大倍数',
                                  hintText: '2',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  DecimalTextInputFormatter(
                                      decimalRange: 2,
                                      minValue: 1,
                                      maxValue: 4),
                                ],
                              ),
                            ),
                          ]))
                    ],
                  )
                ],
              ))
            ]),
      ),
    );
  }
}
