import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  Future<String> download() async{

    var yt = YoutubeExplode();
    Directory('downloads').createSync();

    var link = textController.text.replaceAll('https://www.youtube.com/watch?v=', '');
    var video = await yt.videos.get(link);
    var manifest = await yt.videos.streamsClient.getManifest(link);
    var streams = manifest.muxed;

    var audio = streams.withHighestBitrate();
    var audioStream = yt.videos.streamsClient.get(audio);

    // Compose the file name removing the unallowed characters in windows.
    var fileName = '${video.title}.${audio.container.name}'
        .replaceAll(r'\', '')
        .replaceAll('/', '')
        .replaceAll('*', '')
        .replaceAll('?', '')
        .replaceAll('"', '')
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('|', '');
    var file = File('downloads/$fileName');

    // Delete the file if exists.
    if (file.existsSync()) {
      file.deleteSync();
    }

    // Open the file in writeAppend.
    var output = file.openWrite(mode: FileMode.writeOnlyAppend);

    // Track the file download status.
    var len = audio.size.totalBytes;
    var count = 0;

    // Create the message and set the cursor position.
    var msg = 'Downloading ${video.title}.${audio.container.name}';
    stdout.writeln(msg);

    // Listen for data received.
    //  var progressBar = ProgressBar();
    await for (final data in audioStream) {
      // Keep track of the current downloaded data.
      count += data.length;

      // Calculate the current progress.

        var progress = ((count / len) * 100).ceil();
        print (progress);

      // Update the progressbar.
      // progressBar.update(progress);

      // Write to file.
      output.add(data);
    }

    yt.close();
    await output.close();
    return "0";
  }


  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.grey.shade900,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CupertinoSearchTextField(
                    controller: textController,
                    placeholder: 'Insert Link here',
                    prefixIcon: const SizedBox.shrink(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: CupertinoButton.filled(
                  padding: EdgeInsets.fromLTRB(50, 2, 50, 2),
                  minSize: 35,
                  onPressed: () async{
                    setState(() {
                      download();
                    });
                  },
                  child: const Text('Download',
                    style: TextStyle(
                        color: Colors.white
                    ),),
                ),
              ),
            ],
          ),
          FutureBuilder(
              future: download(),
              builder: (context, snapshot) {
                print(snapshot.data);
                print(snapshot.connectionState);
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CupertinoActivityIndicator();
                } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                  return Text("Download effettuato");
                } else {
                  return Text("");
                }
              })
        ],
      ),
    );
  }
}
