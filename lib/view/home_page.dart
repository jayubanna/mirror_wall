import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../provider/home_provider.dart';

class HomePage extends StatefulWidget {

  const HomePage({super.key,});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  InAppWebViewController? inAppWebViewController;
  PullToRefreshController? pullToRefreshController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false).onChangeLoad(true);
    });
    pullToRefreshController = PullToRefreshController(
      onRefresh: () async {
        if (Platform.isAndroid) {
          inAppWebViewController?.reload();
        } else {
          var webUri = await inAppWebViewController?.getUrl();
          inAppWebViewController?.loadUrl(urlRequest: URLRequest(url: webUri));
        }
      },
    );
  }

  String? selectedValue;
  String? selectedValue1;

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("My Browser"),
        centerTitle: true,
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Provider.of<HomeProvider>(context, listen: false)
                      .change_Android_Theme();
                },
                icon: Icon(
                  Provider.of<HomeProvider>(context).Android_Theme_Mode
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'All Bookmarks',
                                        style: TextStyle(fontSize: 24),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        icon: Icon(Icons.close),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Divider(),
                                  SizedBox(height: 15),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: homeProvider.bookmarks.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          title: Text(
                                              homeProvider.bookmarks[index]),
                                          onTap: () {
                                            inAppWebViewController?.loadUrl(
                                              urlRequest: URLRequest(
                                                url: WebUri(homeProvider
                                                    .bookmarks[index]),
                                              ),
                                            );
                                            Navigator.pop(context);
                                          },
                                          trailing: IconButton(
                                            onPressed: () {
                                              homeProvider.removeBookmark(
                                                  homeProvider
                                                      .bookmarks[index]);
                                            },
                                            icon: Icon(Icons.close),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.bookmark),
                          SizedBox(width: 8),
                          Text("All Bookmarks")
                        ],
                      ),
                    ),
                    value: selectedValue,
                  ),
                  PopupMenuItem(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Search Engine'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: homeProvider.searchEngines.asMap().entries.map((entry) {
                                int idx = entry.key;
                                String name = entry.value['name']!;
                                return Row(
                                  children: [
                                    Radio(
                                      value: idx,
                                      groupValue: homeProvider.searchEngineValue,
                                      onChanged: (value) {
                                        homeProvider.setSearchEngine(value as int);
                                        inAppWebViewController?.loadUrl(
                                          urlRequest: URLRequest(
                                            url: WebUri(homeProvider.searchEngine),
                                          ),
                                        );
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    SizedBox(width: 10.0),
                                    Text(name),
                                  ],
                                );
                              }).toList(),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Close"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Row(
                      children: [
                        Icon(Icons.search_outlined),
                        SizedBox(width: 8),
                        Text("Search Engine")
                      ],
                    ),
                    value: selectedValue1,
                  )
                ],
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(homeProvider.searchEngine),
              ),
              onWebViewCreated: (controller) {
                inAppWebViewController = controller;
              },
              pullToRefreshController: pullToRefreshController,
              onLoadStart: (controller, url) {
                Provider.of<HomeProvider>(context, listen: false)
                    .onChangeLoad(true);
              },
              onProgressChanged: (controller, progress) {
                Provider.of<HomeProvider>(context, listen: false)
                    .onWebProgress(progress / 100);
              },
              onLoadStop: (controller, url) {
                Provider.of<HomeProvider>(context, listen: false)
                    .onChangeLoad(false);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer<HomeProvider>(
              builder: (context, value, child) {
                return TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Search',
                    border: OutlineInputBorder(),
                  ),
                  onFieldSubmitted: (value) {
                    String search = "${homeProvider.searchEngine}$value";
                    inAppWebViewController?.loadUrl(
                      urlRequest: URLRequest(url: WebUri(search)),
                    );
                  },
                );
              },
            ),
          ),
          Consumer<HomeProvider>(
            builder: (BuildContext context, HomeProvider value, Widget? child) {
              if (value.webProgress == 1) {
                return SizedBox();
              } else {
                return LinearProgressIndicator(
                  minHeight: 2.5,
                  value: value.webProgress,
                  color: Colors.blue,
                );
              }
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return HomePage();
                      },
                    ));
                  },
                  icon: Icon(Icons.home)),
              IconButton(
                onPressed: () async {
                  var url = await inAppWebViewController?.getUrl();
                  if (url != null) {
                    homeProvider.addBookmark(url.toString());
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Bookmark saved'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: Icon(
                  Icons.bookmark_add,
                ),
              ),
              IconButton(
                  onPressed: () {
                    inAppWebViewController?.goBack();
                  },
                  icon: Icon(Icons.chevron_left)),
              IconButton(
                  onPressed: () {
                    inAppWebViewController?.reload();
                  },
                  icon: Icon(Icons.refresh)),
              IconButton(
                  onPressed: () {
                    inAppWebViewController?.goForward();
                  },
                  icon: Icon(Icons.chevron_right)),
            ],
          ),
        ],
      ),
    );
  }
}
