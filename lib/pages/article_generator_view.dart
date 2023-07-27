// 文章图片生成器界面
import 'package:flutter/material.dart';

class ArticleGeneratorView extends StatelessWidget {
  const ArticleGeneratorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '显示"文章图片生成器"的内容',
        style: Theme.of(context).textTheme.headline6,
      ),
    );
  }
}