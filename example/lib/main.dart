import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_upchunk/flutter_upchunk.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UpChunk Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'UpChunk Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.title = ''});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ADD ENDPOINT URL HERE
  final _endPoint = '';

  final picker = ImagePicker();

  int _progress = 0;
  bool _uploadComplete = false;
  String _errorMessage = '';

  void _getFile() async {
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile == null) return;

    _uploadFile(File(pickedFile.path));
  }

  void _uploadFile(File fileToUpload) {
    setState(() {
      _progress = 0;
      _uploadComplete = false;
      _errorMessage = '';
    });

    // Chunk upload
    var uploadOptions = UpChunkOptions()
      ..endPoint = _endPoint
      ..file = fileToUpload
      ..headers = {
        'content-name': fileToUpload.path.substring(
          fileToUpload.path.lastIndexOf('/') + 1,
        ),
      }
      ..onProgress = (double progress, _) {
        setState(() {
          _progress = progress.ceil();
        });
      }
      ..onError = (String message, int chunk, int attempts) {
        setState(() {
          _errorMessage = 'UpChunk error 💥 🙀:\n'
              ' - Message: $message\n'
              ' - Chunk: $chunk\n'
              ' - Attempts: $attempts';
        });
      }
      ..onSuccess = () {
        setState(() {
          _uploadComplete = true;
        });
      };

    UpChunk.createUpload(uploadOptions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            if (!_uploadComplete)
              Text(
                'Uploaded: $_progress%',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.normal,
                ),
              ),
            if (_uploadComplete)
              const Text(
                'Upload complete! 👋',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (_errorMessage.isNotEmpty)
              Text(
                '$_errorMessage%',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.normal,
                  color: Colors.red,
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getFile,
        tooltip: 'Get File',
        child: const Icon(Icons.upload_file),
      ),
    );
  }
}
