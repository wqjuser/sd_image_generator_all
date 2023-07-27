import 'package:dio/dio.dart';
import 'package:flash/flash_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sd_image_generator_all/widgets/my_text_field.dart';
import '../net/MyApi.dart';
import '../config/config.dart';
import '../utils/utils.dart';
import 'dart:io';
import 'package:dart_openai/dart_openai.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedMode = 1; // 修改为 int 类型
  int _chatGPTSelectedMode = 0; // 修改为 int 类型
  int _voiceSelectedMode = 0; // 修改为 int 类型
  String _sdUrl = '';
  String _defaultModel = '';
  String _sampler = '';
  String _hiresFixSampler = '';
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
  List<String> _upscalers = ['Latent'];
  String _selectedUpscalers = 'Latent';
  final List<String> _options = ['1.基本提示(通用)', '2.基本提示(通用修手)', '3.基本提示(增加细节1)', '4.基本提示(增加细节2)', '5.基本提示(梦幻童话)'];

  late MyApi myApi;
  late TextEditingController _textFieldController;
  late TextEditingController _loraTextFieldController;
  late TextEditingController _imageSavePathTextFieldController;
  late TextEditingController _hireFix1TextFieldController;
  late TextEditingController _hireFix2TextFieldController;
  late TextEditingController _hireFix3TextFieldController;
  late TextEditingController _picWidthTextFieldController;
  late TextEditingController _picHeightTextFieldController;
  late TextEditingController _draftPathTextFieldController;
  late TextEditingController _chatGPTApiKeyTextFieldController;
  late TextEditingController _selfPositivePromptsTextFieldController;
  late TextEditingController _selfNegativePromptsTextFieldController;
  late TextEditingController _combinedPositivePromptsTextFieldController;
  late TextEditingController _stepsTextFieldController;
  late TextEditingController _baiduTranslateAppIdTextFieldController;
  late TextEditingController _baiduTranslateAppKeyTextFieldController;
  late TextEditingController _baiduVoiceApiKeyTextFieldController;
  late TextEditingController _baiduVoiceSecretKeyTextFieldController;
  late TextEditingController _baiduVoiceAppIdTextFieldController;
  late TextEditingController _deeplTranslateAppKeyTextFieldController;
  late TextEditingController _aliVoiceAccessIdTextFieldController;
  late TextEditingController _aliVoiceAccessSecretTextFieldController;
  late TextEditingController _aliVoiceAppKeyTextFieldController;
  late TextEditingController _huaweiVoiceAKTextFieldController;
  late TextEditingController _huaweiVoiceSKTextFieldController;
  late TextEditingController _azureVoiceSKTextFieldController;
  var content = '正在测试连接，请稍后点击';
  var draftContent = '';

  @override
  void initState() {
    super.initState();
    // 在初始化时创建 MyApi 实例
    myApi = MyApi(Dio());
    _textFieldController = TextEditingController(text: _sdUrl);
    _loraTextFieldController = TextEditingController();
    _draftPathTextFieldController = TextEditingController();
    _chatGPTApiKeyTextFieldController = TextEditingController();
    _selfPositivePromptsTextFieldController = TextEditingController();
    _selfNegativePromptsTextFieldController = TextEditingController();
    _combinedPositivePromptsTextFieldController = TextEditingController();
    _baiduTranslateAppIdTextFieldController = TextEditingController();
    _baiduTranslateAppKeyTextFieldController = TextEditingController();
    _baiduVoiceAppIdTextFieldController = TextEditingController();
    _baiduVoiceApiKeyTextFieldController = TextEditingController();
    _baiduVoiceSecretKeyTextFieldController = TextEditingController();
    _aliVoiceAppKeyTextFieldController = TextEditingController();
    _aliVoiceAccessIdTextFieldController = TextEditingController();
    _aliVoiceAccessSecretTextFieldController = TextEditingController();
    _deeplTranslateAppKeyTextFieldController = TextEditingController();
    _huaweiVoiceAKTextFieldController = TextEditingController();
    _huaweiVoiceSKTextFieldController = TextEditingController();
    _azureVoiceSKTextFieldController = TextEditingController();
    _stepsTextFieldController = TextEditingController(text: '20');
    _hireFix1TextFieldController = TextEditingController(text: '5');
    _hireFix2TextFieldController = TextEditingController(text: '0.5');
    _hireFix3TextFieldController = TextEditingController(text: '2');
    _picWidthTextFieldController = TextEditingController(text: '512');
    _picHeightTextFieldController = TextEditingController(text: '512');
    Map<String, String> envVars = Platform.environment;
    if (Platform.isWindows) {
      _imageSavePathTextFieldController = TextEditingController(text: 'C:/Users/Administrator/Pictures/');
    } else if (Platform.isMacOS) {
      _imageSavePathTextFieldController = TextEditingController(text: '/Users/${envVars['USER']}/Pictures/');
    } else {
      _imageSavePathTextFieldController = TextEditingController(text: '非电脑设备，无法保存图片');
    }
    loadSettings();
  }

  Future<void> testOpenAI(String apiKey, String modelName, String prompts) async {
    content = "正在测试连接，请稍后...";
    Response response = await myApi.testChatGPT(apiKey);
    if (response.statusCode == 200) {
      content = "连接成功";
    }
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
    if (_models.isNotEmpty) {
      for (int i = 0; i < _models.length; i++) {
        if (_models[i] == _defaultModel) {
          _selectedModel = _models[i];
          break;
        }
      }
      if (_selectedModel == "请先获取可用模型列表") {
        _selectedModel = _models[0];
      }
    }
    setState(() {});
  }

  Future<void> _getVaes(String url) async {
    try {
      Response response = await myApi.getSDVaes(url);
      if (response.statusCode == 200) {
        _vaes.clear();
        _vaes.add("无");
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
    if (_vaes.isNotEmpty) {
      _selectedVae = _vaes[0];
    }
    setState(() {});
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
    if (_samplers.isNotEmpty) {
      for (int i = 0; i < _samplers.length; i++) {
        if (_samplers[i] == _sampler) {
          _selectedSampler = _samplers[i];
          break;
        }
      }
      if (_selectedSampler == "Euler a") {
        _selectedSampler = _samplers[0];
      }
    }
    setState(() {});
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
    if (_upscalers.isNotEmpty) {
      for (int i = 0; i < _upscalers.length; i++) {
        if (_upscalers[i] == _hiresFixSampler) {
          _selectedUpscalers = _upscalers[i];
          break;
        }
      }
      if (_selectedUpscalers == 'Latent') {
        _selectedUpscalers = _upscalers[0];
      }
    }
    setState(() {});
  }

  Future<void> loadSettings() async {
    Map<String, dynamic> settings = await Config.loadSettings();
    int? useMode = settings['useMode'];
    String? sdUrl = settings['sdUrl'];
    String? chatGPTApiKey = settings['chat_api_key'];
    bool combinePositivePromptTypes = settings['is_compiled_positive_prompts'];
    bool useSelfPositivePrompts = settings['use_self_positive_prompts'];
    bool useSelfNegativePrompts = settings['use_self_negative_prompts'];
    bool useFaceRestore = settings['restore_face'];
    bool useHiresFix = settings['hires_fix'];
    String selfPositivePrompts = settings['self_positive_prompts'];
    String selfNegativePrompts = settings['self_negative_prompts'];
    String draftSavePath = settings['jy_draft_save_path'];
    String combinedPositivePrompts = settings['compiled_positive_prompts_type'];
    int picWidth = settings['width'];
    int picHeight = settings['height'];
    int steps = settings['steps'];
    String sampler = settings['Sampler'];
    _hiresFixSampler = settings['hires_fix_sampler'];
    String model = settings['default_model'];
    int hiresFixSteps = settings['hires_fix_steps'];
    double hiresFixAmplitude = settings['hires_fix_amplitude'];
    double hiresFixMultiple = settings['hires_fix_multiple'];
    String baiduTranslateAppId = settings['baidu_trans_app_id'];
    String baiduTranslateAppKey = settings['baidu_trans_app_key'];
    String deeplTranslateAppKey = settings['deepl_api_key'];
    String baiduVoiceApiKey = settings['baidu_voice_api_key'];
    String baiduVoiceAppId = settings['baidu_voice_app_id'];
    String baiduVoiceSecretKey = settings['baidu_voice_secret_key'];
    String aliVoiceAccessId = settings['ali_voice_access_id'];
    String aliVoiceAccessSecret = settings['ali_voice_access_secret'];
    String aliVoiceAppKey = settings['ali_voice_app_key'];
    String huaweiVoiceAK = settings['huawei_voice_ak'];
    String huaweiVoiceSK = settings['huawei_voice_sk'];
    String azureVoiceSK = settings['azure_voice_speech_key'];
    setState(() {
      if (sdUrl != null) {
        _sdUrl = sdUrl;
      }
      if (useMode != null) {
        _selectedMode = useMode;
      }
      _defaultModel = model;
      _sampler = sampler;
      _voiceSelectedMode = settings['useVoiceMode'];
      _textFieldController = TextEditingController(text: _sdUrl);
      _chatGPTApiKeyTextFieldController = TextEditingController(text: chatGPTApiKey);
      _selfPositivePromptsTextFieldController = TextEditingController(text: selfPositivePrompts);
      _selfNegativePromptsTextFieldController = TextEditingController(text: selfNegativePrompts);
      _draftPathTextFieldController = TextEditingController(text: draftSavePath);
      _isMixPrompt = combinePositivePromptTypes;
      _isSelfPositivePrompt = useSelfPositivePrompts;
      _isSelfNegativePrompt = useSelfNegativePrompts;
      _isUseFaceStore = useFaceRestore;
      _isHiresFix = useHiresFix;
      _draftPathTextFieldController = TextEditingController(text: draftSavePath);
      _combinedPositivePromptsTextFieldController = TextEditingController(text: combinedPositivePrompts);
      _picWidthTextFieldController = TextEditingController(text: "$picWidth");
      _picHeightTextFieldController = TextEditingController(text: "$picHeight");
      _stepsTextFieldController = TextEditingController(text: "$steps");
      _hireFix1TextFieldController = TextEditingController(text: "$hiresFixSteps");
      _hireFix2TextFieldController = TextEditingController(text: "$hiresFixAmplitude");
      _hireFix3TextFieldController = TextEditingController(text: "$hiresFixMultiple");
      _baiduTranslateAppIdTextFieldController = TextEditingController(text: baiduTranslateAppId);
      _baiduTranslateAppKeyTextFieldController = TextEditingController(text: baiduTranslateAppKey);
      _deeplTranslateAppKeyTextFieldController = TextEditingController(text: deeplTranslateAppKey);
      _baiduVoiceApiKeyTextFieldController = TextEditingController(text: baiduVoiceApiKey);
      _baiduVoiceAppIdTextFieldController = TextEditingController(text: baiduVoiceAppId);
      _baiduVoiceSecretKeyTextFieldController = TextEditingController(text: baiduVoiceSecretKey);
      _aliVoiceAccessIdTextFieldController = TextEditingController(text: aliVoiceAccessId);
      _aliVoiceAppKeyTextFieldController = TextEditingController(text: aliVoiceAccessSecret);
      _aliVoiceAccessSecretTextFieldController = TextEditingController(text: aliVoiceAppKey);
      _huaweiVoiceAKTextFieldController = TextEditingController(text: huaweiVoiceAK);
      _huaweiVoiceSKTextFieldController = TextEditingController(text: huaweiVoiceSK);
      _azureVoiceSKTextFieldController = TextEditingController(text: azureVoiceSK);
      if (_sdUrl != '') {
        //获取可用的sd模型
        _getModels(_sdUrl);
        //获取可用的sd采样方法
        _getSamplers(_sdUrl);
        //获取可用的lora
        _getLoras(_sdUrl);
        //获取可用的vae
        _getVaes(_sdUrl);
        //获取可用的放大算法
        _getUpscalers(_sdUrl);
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
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                Expanded(
                    child: ListView(
                  children: <Widget>[
                    const Text(
                      'Stable Diffusion 相关设置:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const SizedBox(
                      height: 1,
                      child: Divider(
                        color: Colors.black,
                        thickness: 1,
                        indent: 0,
                        endIndent: 0,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _textFieldController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'SD的地址，一般要有端口号',
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
                                    borderRadius: BorderRadius.all(Radius.circular(16)),
                                    side: BorderSide(),
                                  ),
                                  contentPadding: const EdgeInsets.only(left: 24.0, top: 16.0, right: 24.0, bottom: 16.0),
                                  title: const Text('测试结果'),
                                  content: Text(content),
                                  actions: [
                                    TextButton(
                                      onPressed: controller.dismiss,
                                      child: const Text('好的'),
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
                    Row(
                      children: <Widget>[
                        const SizedBox(
                            width: 70, // 设置容器的宽度
                            child: Text('可用模型:')),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButton(
                            value: _selectedModel,
                            items: _models.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) async {
                              Map<String, dynamic> settings = {'default_model': newValue};
                              await Config.saveSettings(settings);
                              Map<String, dynamic> options = {'sd_model_checkpoint': newValue};
                              Response response = await myApi.sdOptions(_textFieldController.text, options);
                              String setResult = '';
                              if (response.statusCode == 200) {
                                setResult = "模型更改成功";
                              } else {
                                setResult = "模型更改失败";
                              }
                              if(context.mounted) {
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
                                      title: const Text('模型更改结果'),
                                      content: Text(setResult),
                                      actions: [
                                        TextButton(
                                          onPressed: controller.dismiss,
                                          child: const Text('好的'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
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
                            items: _loras.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                if (_selectedLora != newValue) {
                                  _loraTextFieldController.text = '${_loraTextFieldController.text}<lora:$newValue:1>, ';
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
                            items: _vaes.map<DropdownMenuItem<String>>((String value) {
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
                          items: _options.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) async {
                            int type = 1;
                            if (newValue != null) {
                              type = int.parse(newValue.split('.')[0]);
                            }
                            Map<String, dynamic> settings = {'default_positive_prompts_type': type};
                            await Config.saveSettings(settings);
                            setState(() {
                              _selectedOption = newValue!;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        Row(children: <Widget>[
                          GestureDetector(
                              onTap: () async {
                                Map<String, dynamic> settings = {'is_compiled_positive_prompts': !_isMixPrompt};
                                await Config.saveSettings(settings);
                                setState(() {
                                  _isMixPrompt = !_isMixPrompt;
                                });
                              },
                              child: Row(
                                children: <Widget>[
                                  Checkbox(
                                    value: _isMixPrompt,
                                    onChanged: (bool? newValue) async {
                                      Map<String, dynamic> settings = {'is_compiled_positive_prompts': newValue ?? false};
                                      await Config.saveSettings(settings);
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
                          child: Expanded(
                            child: TextField(
                              controller: _combinedPositivePromptsTextFieldController,
                              onChanged: (text) async {
                                Map<String, dynamic> settings = {'compiled_positive_prompts_type': text};
                                await Config.saveSettings(settings);
                              },
                              decoration: const InputDecoration(
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
                              onTap: () async {
                                Map<String, dynamic> settings = {
                                  'use_self_positive_prompts': _isSelfPositivePrompt,
                                };
                                await Config.saveSettings(settings);
                                setState(() {
                                  _isSelfPositivePrompt = !_isSelfPositivePrompt;
                                });
                              },
                              child: Row(
                                children: <Widget>[
                                  Checkbox(
                                    value: _isSelfPositivePrompt,
                                    onChanged: (bool? newValue) async {
                                      Map<String, dynamic> settings = {
                                        'use_self_positive_prompts': newValue ?? false,
                                      };
                                      await Config.saveSettings(settings);
                                      setState(() {
                                        _isSelfPositivePrompt = newValue ?? false;
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 2),
                                  const Text(
                                    '自行输入默认正面提示词(勾选后上面的选择将失效)',
                                    overflow: TextOverflow.ellipsis,
                                    // 自动省略为...
                                    maxLines: 1,
                                    // 限制显示的最大行数为1
                                    textAlign: TextAlign.center, // 文本居中
                                  ),
                                ],
                              )),
                        ),
                        Expanded(
                          child: GestureDetector(
                              onTap: () async {
                                Map<String, dynamic> settings = {
                                  'use_self_negative_prompts': !_isSelfNegativePrompt,
                                };
                                await Config.saveSettings(settings);
                                setState(() {
                                  _isSelfNegativePrompt = !_isSelfNegativePrompt;
                                });
                              },
                              child: Row(
                                children: <Widget>[
                                  Checkbox(
                                    value: _isSelfNegativePrompt,
                                    onChanged: (bool? newValue) async {
                                      Map<String, dynamic> settings = {
                                        'use_self_negative_prompts': newValue ?? false,
                                      };
                                      await Config.saveSettings(settings);
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
                            child: Expanded(
                                child: TextField(
                              controller: _selfPositivePromptsTextFieldController,
                              onChanged: (text) async {
                                Map<String, dynamic> settings = {
                                  'self_positive_prompts': text,
                                };
                                await Config.saveSettings(settings);
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: '默认正面提示词，影响每一张图片',
                              ),
                            ))),
                        Visibility(
                          visible: _isSelfNegativePrompt & _isSelfPositivePrompt,
                          child: const SizedBox(width: 6),
                        ),
                        Visibility(
                            visible: _isSelfNegativePrompt,
                            child: Expanded(
                                child: TextField(
                              controller: _selfNegativePromptsTextFieldController,
                              onChanged: (text) async {
                                Map<String, dynamic> settings = {
                                  'self_negative_prompts': text,
                                };
                                await Config.saveSettings(settings);
                              },
                              decoration: const InputDecoration(
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
                                onChanged: (text) async {
                                  Map<String, dynamic> settings = {
                                    'loras': text,
                                  };
                                  await Config.saveSettings(settings);
                                },
                                maxLength: null,
                                controller: _loraTextFieldController,
                                keyboardType: TextInputType.multiline,
                                decoration: const InputDecoration(
                                    hintText: '格式是<lora:lora的名字:lora的权重>,支持多个lora，例如 <lora:fashionGirl_v54:0.5>, <lora:cuteGirlMix4_v10:0.6>',
                                    border: OutlineInputBorder(),
                                    labelText: '使用Lora，注意此处使用的Lora将影响所有图片，从上方可用Lora的列表中选择，请加入Lora触发词'))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        const Text('绘图采样算法:'),
                        const SizedBox(width: 6),
                        DropdownButton(
                          value: _selectedSampler, // 设置选中值
                          items: _samplers.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) async {
                            Map<String, dynamic> settings = {
                              'Sampler': newValue ?? 'Euler a',
                            };
                            await Config.saveSettings(settings);
                            setState(() {
                              _selectedSampler = newValue!;
                            });
                          },
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            onChanged: (text) async {
                              Map<String, dynamic> settings = {
                                'steps': int.parse(text),
                              };
                              await Config.saveSettings(settings);
                            },
                            controller: _stepsTextFieldController,
                            decoration: const InputDecoration(
                              labelText: '绘图迭代步数',
                              hintText: '20',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                          ),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 200,
                          child: TextField(
                            onChanged: (text) async {
                              Map<String, dynamic> settings = {
                                'width': int.parse(text),
                              };
                              await Config.saveSettings(settings);
                            },
                            controller: _picWidthTextFieldController,
                            decoration: const InputDecoration(
                              labelText: '绘图图片宽度(范围是64-2048)',
                              hintText: '512',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                          ),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 200,
                          child: TextField(
                            onChanged: (text) async {
                              Map<String, dynamic> settings = {
                                'height': int.parse(text),
                              };
                              await Config.saveSettings(settings);
                            },
                            controller: _picHeightTextFieldController,
                            decoration: const InputDecoration(
                              labelText: '绘图图片高度(范围64-2048)',
                              hintText: '512',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () async {
                            Map<String, dynamic> settings = {
                              'restore_face': !_isUseFaceStore,
                            };
                            await Config.saveSettings(settings);
                            setState(() {
                              _isUseFaceStore = !_isUseFaceStore;
                            });
                          },
                          child: Row(children: <Widget>[
                            Checkbox(
                              value: _isUseFaceStore,
                              onChanged: (bool? newValue) async {
                                Map<String, dynamic> settings = {
                                  'restore_face': newValue ?? false,
                                };
                                await Config.saveSettings(settings);
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
                          onTap: () async {
                            Map<String, dynamic> settings = {
                              'hires_fix': !_isHiresFix,
                            };
                            await Config.saveSettings(settings);
                            setState(() {
                              _isHiresFix = !_isHiresFix;
                            });
                          },
                          child: Row(children: <Widget>[
                            Checkbox(
                              value: _isHiresFix,
                              onChanged: (bool? newValue) async {
                                Map<String, dynamic> settings = {
                                  'hires_fix': newValue ?? false,
                                };
                                await Config.saveSettings(settings);
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
                                items: _upscalers.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) async {
                                  Map<String, dynamic> settings = {
                                    'hires_fix_sampler': newValue,
                                  };
                                  await Config.saveSettings(settings);
                                  setState(() {
                                    _selectedUpscalers = newValue!;
                                  });
                                },
                              ),
                              const SizedBox(width: 6),
                              SizedBox(
                                width: 100,
                                child: TextField(
                                  onChanged: (text) async {
                                    Map<String, dynamic> settings = {
                                      'hires_fix_steps': int.parse(text),
                                    };
                                    await Config.saveSettings(settings);
                                  },
                                  controller: _hireFix1TextFieldController,
                                  decoration: const InputDecoration(
                                    labelText: '高清迭代步数',
                                    hintText: '5',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                                ),
                              ),
                              const SizedBox(width: 6),
                              SizedBox(
                                width: 100,
                                child: TextField(
                                  onChanged: (text) async {
                                    Map<String, dynamic> settings = {
                                      'hires_fix_amplitude': double.parse(text),
                                    };
                                    await Config.saveSettings(settings);
                                  },
                                  controller: _hireFix2TextFieldController,
                                  decoration: const InputDecoration(
                                    labelText: '高清重绘幅度',
                                    hintText: '0.5',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    DecimalTextInputFormatter(decimalRange: 2, minValue: 0, maxValue: 1),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              SizedBox(
                                width: 100,
                                child: TextField(
                                  onChanged: (text) async {
                                    Map<String, dynamic> settings = {
                                      'hires_fix_multiple': double.parse(text),
                                    };
                                    await Config.saveSettings(settings);
                                  },
                                  controller: _hireFix3TextFieldController,
                                  decoration: const InputDecoration(
                                    labelText: '高清放大倍数',
                                    hintText: '2',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    DecimalTextInputFormatter(decimalRange: 2, minValue: 1, maxValue: 4),
                                  ],
                                ),
                              ),
                            ])),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _imageSavePathTextFieldController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: '图片默认保存根目录',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                            onPressed: () async {
                              if (_imageSavePathTextFieldController.text.isNotEmpty) {
                                Map<String, dynamic> settings = {
                                  'image_save_path': _imageSavePathTextFieldController.text,
                                };
                                await Config.saveSettings(settings);
                                draftContent = '图片保存路径设置成功';
                              } else {
                                draftContent = '路径为空不能设置，将使用上次的成功配置';
                              }
                              // ignore: use_build_context_synchronously
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
                                    title: const Text('设置'),
                                    content: Text(draftContent),
                                    actions: [
                                      TextButton(
                                        onPressed: controller.dismiss,
                                        child: const Text('好的'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: const Text('设置'))
                      ],
                    ),
                    // TODO 这里添加新的功能视图
                    const SizedBox(height: 16),
                    const Text(
                      'ChatGPT 相关设置:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const SizedBox(
                      height: 1,
                      child: Divider(
                        color: Colors.black,
                        thickness: 1,
                        indent: 0,
                        endIndent: 0,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Visibility(
                      visible: true,
                      child: Row(
                        children: <Widget>[
                          const Text('使用模式：'),
                          Expanded(
                            child: RadioListTile<int>(
                              title: const Text('api'),
                              value: 0,
                              groupValue: _chatGPTSelectedMode,
                              onChanged: (value) async {
                                Map<String, dynamic> settings = {
                                  'ChatGPTUseMode': value!,
                                };
                                await Config.saveSettings(settings);
                                setState(() {
                                  _chatGPTSelectedMode = value;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<int>(
                              title: const Text('web'),
                              value: 1,
                              groupValue: _chatGPTSelectedMode,
                              onChanged: (value) async {
                                Map<String, dynamic> settings = {
                                  'ChatGPTUseMode': value!,
                                };
                                await Config.saveSettings(settings);
                                setState(() {
                                  _chatGPTSelectedMode = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    //chatgpt api-key
                    Visibility(
                      visible: _chatGPTSelectedMode == 0,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: MyTextField(
                              controller: _chatGPTApiKeyTextFieldController,
                              onChanged: (value) async {
                                Map<String, dynamic> settings = {
                                  'chat_api_key': value,
                                };
                                await Config.saveSettings(settings);
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'sk-xxxxxxxxxxxx',
                                labelText: 'ChatGPT的API-KEY',
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                              onPressed: () async {
                                await testOpenAI(_chatGPTApiKeyTextFieldController.text, "gpt-3.5-turbo-0301", "你好,请回答我测试成功");
                                // ignore: use_build_context_synchronously
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
                              child: const Text('测试连接')),
                        ],
                      ),
                    ),
                    //chatgpt key pwd
                    Visibility(
                      visible: _chatGPTSelectedMode == 1,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              onChanged: (text) async {
                                Map<String, dynamic> settings = {
                                  'chat_account': text,
                                };
                                await Config.saveSettings(settings);
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'xxxxxx@xxxx.com',
                                labelText: 'ChatGPT的账号',
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextField(
                              onChanged: (text) async {
                                Map<String, dynamic> settings = {
                                  'chat_password': text,
                                };
                                await Config.saveSettings(settings);
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'xxxxxxxxxxxx',
                                labelText: 'ChatGPT的密码',
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                              onPressed: () async {
                                await testOpenAI(_chatGPTApiKeyTextFieldController.text, "gpt-3.5-0301", "你好");
                                // ignore: use_build_context_synchronously
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
                              child: const Text('测试连接')),
                        ],
                      ),
                    ),
                    //百度翻译设置视图
                    const SizedBox(height: 16),
                    const Text(
                      '百度翻译 相关设置:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const SizedBox(
                      height: 1,
                      child: Divider(
                        color: Colors.black,
                        thickness: 1,
                        indent: 0,
                        endIndent: 0,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: MyTextField(
                            controller: _baiduTranslateAppIdTextFieldController,
                            onChanged: (text) async {
                              Map<String, dynamic> settings = {
                                'baidu_trans_app_id': text,
                              };
                              await Config.saveSettings(settings);
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: '百度翻译的APPID',
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: MyTextField(
                            controller: _baiduTranslateAppKeyTextFieldController,
                            onChanged: (text) async {
                              Map<String, dynamic> settings = {
                                'baidu_trans_app_key': text,
                              };
                              await Config.saveSettings(settings);
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: '百度翻译的KEY',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'DEEPL翻译 相关设置:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const SizedBox(
                      height: 1,
                      child: Divider(
                        color: Colors.black,
                        thickness: 1,
                        indent: 0,
                        endIndent: 0,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: MyTextField(
                            controller: _deeplTranslateAppKeyTextFieldController,
                            onChanged: (text) async {
                              Map<String, dynamic> settings = {
                                'deepl_api_key': text,
                              };
                              await Config.saveSettings(settings);
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'DEEPL翻译的API_KEY',
                            ),
                          ),
                        ),
                      ],
                    ),
                    //语音相关配置视图
                    const SizedBox(height: 16),
                    const Text(
                      '语音 相关设置:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const SizedBox(
                      height: 1,
                      child: Divider(
                        color: Colors.black,
                        thickness: 1,
                        indent: 0,
                        endIndent: 0,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Visibility(
                      visible: true,
                      child: Row(
                        children: <Widget>[
                          const Text('语音引擎：'),
                          Expanded(
                            child: RadioListTile<int>(
                              title: const Text('百度语音'),
                              value: 0,
                              groupValue: _voiceSelectedMode,
                              onChanged: (value) async {
                                Map<String, dynamic> settings = {
                                  'useVoiceMode': value!,
                                };
                                await Config.saveSettings(settings);
                                setState(() {
                                  _voiceSelectedMode = value;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<int>(
                              title: const Text('阿里语音'),
                              value: 1,
                              groupValue: _voiceSelectedMode,
                              onChanged: (value) async {
                                Map<String, dynamic> settings = {
                                  'useVoiceMode': value!,
                                };
                                await Config.saveSettings(settings);
                                setState(() {
                                  _voiceSelectedMode = value;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<int>(
                              title: const Text('华为语音'),
                              value: 2,
                              groupValue: _voiceSelectedMode,
                              onChanged: (value) async {
                                Map<String, dynamic> settings = {
                                  'useVoiceMode': value!,
                                };
                                await Config.saveSettings(settings);
                                setState(() {
                                  _voiceSelectedMode = value;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<int>(
                              title: const Text('微软语音'),
                              value: 3,
                              groupValue: _voiceSelectedMode,
                              onChanged: (value) async {
                                Map<String, dynamic> settings = {
                                  'useVoiceMode': value!,
                                };
                                await Config.saveSettings(settings);
                                setState(() {
                                  _voiceSelectedMode = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Visibility(
                      visible: _voiceSelectedMode == 0,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: MyTextField(
                              controller: _baiduVoiceApiKeyTextFieldController,
                              onChanged: (value) async {
                                Map<String, dynamic> settings = {
                                  'baidu_voice_api_key': value,
                                };
                                await Config.saveSettings(settings);
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: '百度语音的API_KEY',
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Expanded(
                            child: MyTextField(
                              controller: _baiduVoiceSecretKeyTextFieldController,
                              onChanged: (value) async {
                                Map<String, dynamic> settings = {
                                  'baidu_voice_secret_key': value,
                                };
                                await Config.saveSettings(settings);
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: '百度语音的SECRET_KEY',
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Expanded(
                            child: MyTextField(
                              controller: _baiduVoiceAppIdTextFieldController,
                              onChanged: (value) async {
                                Map<String, dynamic> settings = {
                                  'baidu_voice_app_id': value,
                                };
                                await Config.saveSettings(settings);
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: '百度语音的APP_ID',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: _voiceSelectedMode == 1,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: MyTextField(
                              controller: _aliVoiceAccessIdTextFieldController,
                              onChanged: (value) async {
                                Map<String, dynamic> settings = {
                                  'ali_voice_access_id': value,
                                };
                                await Config.saveSettings(settings);
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: '阿里语音的ACCESS_ID',
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Expanded(
                            child: MyTextField(
                              controller: _aliVoiceAccessSecretTextFieldController,
                              onChanged: (value) async {
                                Map<String, dynamic> settings = {
                                  'ali_voice_access_secret': value,
                                };
                                await Config.saveSettings(settings);
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: '阿里语音的ACCESS_SECRET',
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Expanded(
                            child: MyTextField(
                              controller: _aliVoiceAppKeyTextFieldController,
                              onChanged: (value) async {
                                Map<String, dynamic> settings = {
                                  'ali_voice_app_key': value,
                                };
                                await Config.saveSettings(settings);
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: '阿里语音的APP_KEY',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: _voiceSelectedMode == 2,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: MyTextField(
                              controller: _huaweiVoiceAKTextFieldController,
                              onChanged: (value) async {
                                Map<String, dynamic> settings = {
                                  'huawei_voice_ak': value,
                                };
                                await Config.saveSettings(settings);
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: '华为语音的AK',
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Expanded(
                            child: MyTextField(
                              controller: _huaweiVoiceSKTextFieldController,
                              onChanged: (value) async {
                                Map<String, dynamic> settings = {
                                  'huawei_voice_sk': value,
                                };
                                await Config.saveSettings(settings);
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: '华为语音的SK',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: _voiceSelectedMode == 3,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: MyTextField(
                              controller: _azureVoiceSKTextFieldController,
                              onChanged: (value) async {
                                Map<String, dynamic> settings = {
                                  'azure_voice_speech_key': value,
                                };
                                await Config.saveSettings(settings);
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: '微软语音的SPEECH_KEY',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '剪映草稿 相关设置:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const SizedBox(
                      height: 1,
                      child: Divider(
                        color: Colors.black,
                        thickness: 1,
                        indent: 0,
                        endIndent: 0,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _draftPathTextFieldController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '',
                            labelText: '剪映草稿的保存路径',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                          onPressed: () async {
                            if (_draftPathTextFieldController.text.isNotEmpty) {
                              Map<String, dynamic> settings = {
                                'jy_draft_save_path': _draftPathTextFieldController.text,
                              };
                              await Config.saveSettings(settings);
                              draftContent = '剪映草稿保存路径设置成功';
                            } else {
                              draftContent = '路径为空不能设置，将使用上次的成功配置';
                            }
                            // ignore: use_build_context_synchronously
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
                                  title: const Text('设置'),
                                  content: Text(draftContent),
                                  actions: [
                                    TextButton(
                                      onPressed: controller.dismiss,
                                      child: const Text('好的'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: const Text('设置'))
                    ]),
                    const SizedBox(height: 16), //页面底部距离，在这个上面添加需要的视图
                  ],
                ))
              ]))),
    );
  }
}
