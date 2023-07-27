//随机图片生成界面
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sd_image_generator_all/widgets/image_show_view.dart';
import '../config/config.dart';
import '../net/MyApi.dart';
import '../params/prompts.dart';
import '../params/prompts_styles.dart';

class RandomGeneratorView extends StatefulWidget {
  const RandomGeneratorView({super.key});

  @override
  State<StatefulWidget> createState() => _RandomGeneratorViewState();
}

@immutable
class DealResult {
  final int width;
  final int height;
  final bool pm;
  final String negativePrompt;
  final bool isReal;
  final bool addRandomPrompts;

  const DealResult({
    required this.width,
    required this.height,
    required this.pm,
    required this.negativePrompt,
    required this.isReal,
    required this.addRandomPrompts,
  });
}

class _RandomGeneratorViewState extends State<RandomGeneratorView> {
  late TextEditingController _textFieldController;
  late TextEditingController _picContentTextFieldController;
  List<String> imageBase64List = [];
  late MyApi myApi;
  List<List<dynamic>> promptsLists = [
    prompts['camera_perspective_prompts'],
    prompts['person_prompts'],
    prompts['career_prompts'],
    prompts['facial_features_prompts'],
    prompts['light_prompts'],
    prompts['expression_prompts'],
    prompts['hair_prompts'],
    prompts['decoration_prompts'],
    prompts['hat_prompts'],
    prompts['shoes_prompts'],
    prompts['socks_prompts'],
    prompts['gesture_prompt'],
    prompts['sight_prompts'],
    prompts['environment_prompts'],
    prompts['style_prompts'],
    prompts['action_prompts'],
    prompts['actions_prompts'],
    prompts['clothes_prompts'],
    prompts['clothes_prompts2'],
  ];
  List<List<dynamic>> animePromptsLists = [
    prompts['anime_characters_prompts'],
    prompts['camera_perspective_prompts'],
    prompts['person_prompts'],
    prompts['career_prompts'],
    prompts['facial_features_prompts'],
    prompts['light_prompts'],
    prompts['expression_prompts'],
    prompts['hair_prompts'],
    prompts['decoration_prompts'],
    prompts['hat_prompts'],
    prompts['shoes_prompts'],
    prompts['socks_prompts'],
    prompts['gesture_prompt'],
    prompts['sight_prompts'],
    prompts['environment_prompts'],
    prompts['style_prompts'],
    prompts['action_prompts'],
    prompts['actions_prompts'],
    prompts['clothes_prompts'],
    prompts['clothes_prompts2'],
  ];
  List<String> loraPrompts = ['lora:cuteGirlMix4_v10', 'lora:koreandolllikenessV20_v20', 'lora:taiwanDollLikeness_v20', 'lora:japanesedolllikenessV1_v15'];
  List<double> loraWeights = [];
  String combinedLoraPromptsString = '';
  int specialIndex = 0;

  String randomPromptSelection(List<List<dynamic>> promptLists) {
    List<String> selectedPrompts = [];

    // 随机选择 action_prompts 或 actions_prompts 中的一个元素
    List<dynamic> actionAndActions = promptLists.sublist(promptLists.length - 4, promptLists.length - 2);
    List<dynamic> selectedActionList = actionAndActions[Random().nextInt(actionAndActions.length)];
    String selectedAction = "";
    if (selectedActionList[0] is String) {
      selectedAction = selectedActionList[Random().nextInt(selectedActionList.length)];
    } else {
      List<dynamic> selectedList = selectedActionList[Random().nextInt(selectedActionList.length)];
      selectedAction = selectedList[Random().nextInt(selectedList.length)];
    }

    // 随机选择 clothes_prompts 或 clothes_prompts2 中的一个元素
    List<dynamic> clothesAndClothes2 = promptLists.sublist(promptLists.length - 2);
    List<dynamic> selectedClothesList = clothesAndClothes2[Random().nextInt(clothesAndClothes2.length)];
    String selectedClothes = "";
    if (selectedClothesList[0] is String) {
      selectedClothes = selectedClothesList[Random().nextInt(selectedClothesList.length)];
    } else {
      List<dynamic> selectedList = selectedClothesList[Random().nextInt(selectedClothesList.length)];
      selectedClothes = selectedList[Random().nextInt(selectedList.length)];
    }

    // 其他的prompt列表
    List<List<dynamic>> otherPrompts = promptLists.sublist(0, promptLists.length - 4);

    for (var promptList in otherPrompts) {
      if (promptList[0] is List) {
        String combinedPrompts = (promptList as List<List<dynamic>>).map((subList) => subList[Random().nextInt(subList.length)]).join(", ");
        selectedPrompts.add(combinedPrompts);
      } else {
        selectedPrompts.add(promptList[Random().nextInt(promptList.length)]);
      }
    }

    // 将随机选择的 action 和 clothes 添加到结果中
    selectedPrompts.add(selectedAction);
    selectedPrompts.add(selectedClothes);

    return selectedPrompts.join(", ");
  }

  List<double> randomWeights(int numWeights, {double minWeight = 0.1, double maxSum = 1.0, int? specialIndex, double? specialMin, double? specialMax}) {
    while (true) {
      List<double> weights =
          List<double>.generate(numWeights - 1, (_) => double.parse((Random().nextDouble() * (maxSum - minWeight * (numWeights - 1)) + minWeight).toStringAsFixed(1)));

      if (specialIndex != null) {
        double specialWeight = double.parse((Random().nextDouble() * (specialMax! - specialMin!) + specialMin).toStringAsFixed(1));
        weights.insert(specialIndex, specialWeight);
      }

      double weightsSum = weights.reduce((a, b) => a + b);
      double lastWeight = double.parse((maxSum - weightsSum).toStringAsFixed(1));

      if (minWeight <= lastWeight && lastWeight <= maxSum) {
        weights.add(lastWeight);
        return weights;
      }
    }
  }

  Map<String, dynamic> parseArgs(String argsStr, [dynamic defaultValue]) {
    var argDict = <String, dynamic>{};
    var argName;
    var argValues = <dynamic>[];

    if (argsStr != "") {
      for (var arg in argsStr.split(" ")) {
        if (arg.startsWith("--")) {
          if (argName != null) {
            if (argValues.length == 1) {
              argDict[argName] = argValues[0];
            } else if (argValues.length > 1) {
              argDict[argName] = argValues;
            } else {
              argDict[argName] = defaultValue;
            }
          }
          argName = arg.substring(2);
          argValues = [];
        } else {
          if (argName == null) {
            argValues.add(arg);
          } else {
            if (arg.contains(", ")) {
              var values = arg.split(", ").map((value) => value.trim()).toList();
              argValues.addAll(values);
            } else {
              argValues.add(arg);
            }
          }
        }
      }

      if (argName != null) {
        if (argValues.length == 1) {
          argDict[argName] = argValues[0];
        } else if (argValues.length > 1) {
          argDict[argName] = argValues;
        } else {
          argDict[argName] = defaultValue;
        }
      }
    }

    return argDict;
  }

  DealResult dealWithArgs(Map<String, dynamic> parsedArgs) {
    int width = 512;
    int height = 512;
    bool pm = false;
    String negativePrompt = '';
    bool isReal = false;
    bool addRandomPrompts = false;

    if (parsedArgs.isNotEmpty) {
      if (parsedArgs.containsKey('ar')) {
        var arValue = parsedArgs['ar'];
        if (arValue == '1:1') {
          width = 512;
          height = 512;
        } else if (arValue == '3:4') {
          width = 768;
          height = 1024;
        } else if (arValue == '4:3') {
          width = 1024;
          height = 768;
        } else if (arValue == '9:16') {
          width = 576;
          height = 1024;
        } else if (arValue == '16:9') {
          width = 1024;
          height = 576;
        }
      }
      if (parsedArgs.containsKey('pm')) {
        pm = true;
      }
      if (parsedArgs.containsKey('real')) {
        isReal = true;
      }
      if (parsedArgs.containsKey('arp')) {
        addRandomPrompts = true;
      }

      if (parsedArgs.containsKey('np')) {
        negativePrompt = parsedArgs['np'];
        // 去除多个逗号
        negativePrompt = negativePrompt.replaceAll(RegExp(',+'), ', ');
        // 去除多个空格
        negativePrompt = negativePrompt.replaceAll(RegExp(r'\s+'), ' ');
      }
    }

    return DealResult(
      width: width,
      height: height,
      pm: pm,
      negativePrompt: negativePrompt,
      isReal: isReal,
      addRandomPrompts: addRandomPrompts,
    );
  }

  String getPrompts(Map<String, dynamic> defaultPromptDict, String promptKeys) {
    List<String> keys = promptKeys.split('+').map((key) => '${int.parse(key)}.').toList();
    String resultStr = '';

    for (String key in keys) {
      String? dictKey = defaultPromptDict.keys.firstWhere((k) => k.startsWith(key), orElse: () => '');
      if (dictKey.isNotEmpty) {
        resultStr += '${defaultPromptDict[dictKey]}, ';
      }
    }

    resultStr = resultStr.replaceAll(RegExp(r',(?!\s)'), ', ');
    resultStr = resultStr.replaceAll(', , ', ', ');
    List<String> words = resultStr.split(', ');
    List<String> finalWords = words.toSet().toList();
    resultStr = finalWords.join(', ');
    List<String> tags = RegExp(r'<.*?>, ').allMatches(resultStr).map((match) => match.group(0)!).toList();
    resultStr = resultStr.replaceAll(RegExp(r'<.*?>, '), '');
    resultStr += tags.join('');
    return resultStr;
  }

  @override
  void initState() {
    _textFieldController = TextEditingController(text: "1");
    _picContentTextFieldController = TextEditingController();
    specialIndex = loraPrompts.indexOf('lora:cuteGirlMix4_v10');
    loraWeights = randomWeights(loraPrompts.length, specialIndex: specialIndex, specialMin: 0.4, specialMax: 0.6);
    combinedLoraPromptsString = loraPrompts.asMap().entries.map((entry) {
      return '<${entry.value}:${loraWeights[entry.key]}>';
    }).join(', ');
    super.initState();
    myApi = MyApi(Dio());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          Row(children: <Widget>[
            SizedBox(
              width: 180,
              child: TextField(
                controller: _textFieldController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '请输入要绘制的图片数量',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                  controller: _picContentTextFieldController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '请输入要绘制的图片内容，留空图片将完全随机',
                  )),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
                onPressed: () async {
                  Map<String, dynamic> defaultPromptDict = {
                    "1.基本提示(通用)": promptsStyles['default_prompts'],
                    "2.基本提示(通用修手)": promptsStyles['default_prompts_fix_hands'],
                    "3.基本提示(增加细节1)": promptsStyles['default_prompts_add_details_1'],
                    "4.基本提示(增加细节2)": promptsStyles['default_prompts_add_details_2'],
                    "5.基本提示(梦幻童话)": promptsStyles['default_prompts_fairy_tale']
                  };
                  Map<String, dynamic> settings = await Config.loadSettings();
                  bool useFaceRestore = settings['restore_face'];
                  bool useHiresFix = settings['hires_fix'];
                  bool combinedPositivePrompts = settings['is_compiled_positive_prompts'];
                  bool useSelfPositivePrompts = settings['use_self_positive_prompts'];
                  bool useSelfNegativePrompts = settings['use_self_negative_prompts'];
                  String defaultPositivePromptType = settings['default_positive_prompts_type'].toString();
                  String combinedPositivePromptsTypes = settings['compiled_positive_prompts_type'];
                  String defaultPositivePrompts = '';
                  String defaultNegativePrompts = settings['self_negative_prompts'];
                  String sdUrl = settings['sdUrl'];
                  int? imageNum = int.tryParse(_textFieldController.text);
                  String imageContent = _picContentTextFieldController.text;
                  DealResult result = const DealResult(width: 512, height: 512, pm: false, negativePrompt: "", isReal: false, addRandomPrompts: false);
                  if (imageContent != "") {
                    Map<String, dynamic> args = parseArgs(imageContent);
                    result = dealWithArgs(args);
                  }
                  if (imageNum != null && imageNum > 0) {
                    imageBase64List.clear();
                    for (int i = 0; i < imageNum; i++) {
                      Map<String, dynamic> requestBody = {};
                      String randomPrompts = '';
                      if (!combinedPositivePrompts & !useSelfPositivePrompts) {
                        for (int i = 0; i < defaultPromptDict.length; i++) {
                          String key = defaultPromptDict.keys.elementAt(i).toString();
                          if (key.startsWith(defaultPositivePromptType)) {
                            defaultPositivePrompts = defaultPromptDict.values.elementAt(i);
                          }
                        }
                      } else if (combinedPositivePrompts & !useSelfPositivePrompts) {
                        defaultPositivePrompts = getPrompts(defaultPromptDict, combinedPositivePromptsTypes);
                      } else if (useSelfPositivePrompts) {
                        defaultPositivePrompts = settings['self_positive_prompts'];
                      }
                      if (result.isReal) {
                        if (useSelfNegativePrompts & defaultNegativePrompts.isNotEmpty) {
                          requestBody['negative_prompt'] = defaultNegativePrompts;
                        } else {
                          requestBody['negative_prompt'] = prompts['real_person_negative_prompt'];
                        }
                        randomPrompts = randomPromptSelection(promptsLists);
                        defaultPositivePrompts = '${defaultPositivePrompts}mix4, $combinedLoraPromptsString';
                      } else {
                        if (useSelfNegativePrompts & defaultNegativePrompts.isNotEmpty) {
                          requestBody['negative_prompt'] = defaultNegativePrompts;
                        } else {
                          requestBody['negative_prompt'] = prompts['anime_negative_prompt'];
                        }
                        randomPrompts = randomPromptSelection(animePromptsLists);
                      }
                      if (imageContent == "") {
                        requestBody['prompt'] = "$defaultPositivePrompts, $randomPrompts";
                      } else {
                        if (result.addRandomPrompts) {
                          if(imageContent.startsWith("--")){
                            requestBody['prompt'] = "$defaultPositivePrompts, $randomPrompts";
                          }else{
                            requestBody['prompt'] = "$defaultPositivePrompts$imageContent, $randomPrompts";
                          }

                        } else {
                          if(imageContent.startsWith("--")){
                            requestBody['prompt'] = "$defaultPositivePrompts, ";
                          }else{
                            requestBody['prompt'] = "$defaultPositivePrompts, $imageContent";
                          }
                        }
                      }
                      requestBody['restore_faces'] = useFaceRestore;
                      requestBody['enable_hr'] = useHiresFix;
                      if (useHiresFix) {
                        requestBody['hr_scale'] = settings['hires_fix_multiple'];
                        requestBody['hr_upscaler'] = settings['hires_fix_sampler'];
                        requestBody['hr_second_pass_steps'] = settings['hires_fix_steps'];
                        requestBody['denoising_strength'] = settings['hires_fix_amplitude'];
                      }
                      requestBody['steps'] = settings['steps'];
                      requestBody['width'] = result.width;
                      requestBody['height'] = result.height;
                      requestBody['cfg_scale'] = 7;
                      Response response = await myApi.sdText2Image(sdUrl, requestBody);
                      if (response.statusCode == 200) {
                        if (response.data['images'] is List<dynamic>) {
                          for (int i = 0; i < response.data['images'].length; i++) {
                            imageBase64List.add(response.data['images'][i]);
                          }
                          setState(() {});
                        }
                      }
                    }
                  }
                },
                child: const Text('开始作图'))
          ]),
          const SizedBox(
            height: 16,
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                ImageView(imageBase64List: imageBase64List),
              ],
            ),
          )
        ],
      ),
    ));
  }
}
