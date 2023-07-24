//随机图片生成界面
import 'package:flutter/material.dart';

class RandomGeneratorView extends StatelessWidget {
  const RandomGeneratorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '显示"随机图片生成器"的内容',
        style: Theme.of(context).textTheme.headline6,
      ),
    );
  }
}
