// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';
import 'package:translator_app/components/text_area.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

final url = Uri.parse(
    'https://google-translate1.p.rapidapi.com/language/translate/v2/languages');

var languages = [];
var filteredData = languages;

final Map<String, String> translateData = {
  "source": "auto",
  "target": "hi",
};
final _sourceController = TextEditingController();
final _resController = TextEditingController();
final _searchController = TextEditingController();

class _HomePageState extends State<HomePage> {
  @override
  initState() {
    super.initState();
    getData();
  }

  getData() async {
    final response = await http.get(url, headers: {
      'Accept-Encoding': 'application/gzip',
      'X-RapidAPI-Key': '93018c5c0amsh92afddf121385f3p1cd73ejsncc93f11d54b3',
      'X-RapidAPI-Host': 'google-translate1.p.rapidapi.com'
    });
    final result = json.decode(response.body);
    setState(() {
      result['data']['languages']
          .forEach((r) => {languages.add(r['language'])});
    });
  }

  double _bottomSheetHeight = 0;
  String _langSelectorBtn = "source";
  String _translateBtnText = "Translate";

  void hideBottomSheet() {
    setState(() {
      _bottomSheetHeight = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.translate),
        title: const Text("Translator App"),
        titleSpacing: 8,
      ),
      bottomSheet: buildBottomSheet(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          openBottomSheet("source");
                        },
                        child: Text(translateData['source']!),
                      ),
                      const Icon(Icons.swap_horiz_rounded,
                          color: Colors.deepPurple),
                      ElevatedButton(
                        onPressed: () {
                          openBottomSheet("target");
                        },
                        child: Text(translateData['target']!),
                      ),
                    ],
                  ),
                ),
                TextArea(
                  textController: _sourceController,
                  setHeight: hideBottomSheet,
                ),
                TextArea(
                  textController: _resController,
                  setHeight: hideBottomSheet,
                ),
                FilledButton.icon(
                  onPressed: () {
                    translate(context);
                  },
                  icon: const Icon(Icons.translate, size: 20),
                  label: Text(_translateBtnText),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void openBottomSheet(String btn) {
    setState(() {
      _langSelectorBtn = btn;
      _bottomSheetHeight = 400;
    });
  }

  BottomSheet buildBottomSheet() {
    return BottomSheet(
      onClosing: () {},
      builder: (context) => SizedBox(
        height: _bottomSheetHeight,
        child: languages.isEmpty
            ? const Center(
                child: Text("Loading languages..."),
              )
            : SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              filteredData = value.isNotEmpty
                                  ? languages
                                      .where((lang) => lang.contains(value))
                                      .toList()
                                  : languages;
                            });
                          }),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredData.length,
                        itemBuilder: (_, index) => ListTile(
                          title: Text(filteredData[index]),
                          onTap: () {
                            setState(() {
                              translateData[_langSelectorBtn] =
                                  filteredData[index];
                              _bottomSheetHeight = 0;
                              _searchController.clear();
                              filteredData = languages;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void toggleText(String text) {
    setState(() {
      _translateBtnText = text;
    });
  }

  void translate(BuildContext context) async {
    final translator = GoogleTranslator();
    toggleText("Translating...");
    var res;
    if (_sourceController.value.text.isNotEmpty) {
      if (translateData['source'] != null) {
        res = await translator.translate(_sourceController.value.text,
            from: translateData['source']!, to: translateData['target']!);
      } else {
        res = await translator.translate(_sourceController.value.text,
            to: translateData['target']!);
      }
      _resController.text = res.toString();
      toggleText("Translate");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please write something!"),
          backgroundColor: Colors.red[400],
        ),
      );
    }
  }
}
