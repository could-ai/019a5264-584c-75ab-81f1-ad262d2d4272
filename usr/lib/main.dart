import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Model for a scanned document
class ScannedDocument {
  final String id;
  final String imagePath;
  String name;

  ScannedDocument({required this.id, required this.imagePath, required this.name});
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Document Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<ScannedDocument> _scannedDocs = [];
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();

  Future<void> _scanDocument() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        final newDoc = ScannedDocument(
          id: DateTime.now().toString(),
          imagePath: image.path,
          name: 'Untitled Document',
        );
        _scannedDocs.add(newDoc);
      });
    }
  }

  void _saveDocumentName() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a document name')),
      );
      return;
    }
    setState(() {
      final int docIndex = _scannedDocs.lastIndexWhere((doc) => doc.name == 'Untitled Document');
      if (docIndex != -1) {
        _scannedDocs[docIndex].name = _nameController.text.trim();
        _nameController.clear();
        FocusScope.of(context).unfocus(); // Dismiss keyboard
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Scan a new document before saving a name.')),
        );
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Scanner App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _scanDocument,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan Document'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Enter document name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveDocumentName,
              child: const Text('Save Document Name'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Scanned Documents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: _scannedDocs.isEmpty
                  ? const Center(child: Text('No documents scanned yet.'))
                  : ListView.builder(
                      itemCount: _scannedDocs.length,
                      itemBuilder: (context, index) {
                        final doc = _scannedDocs[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            leading: Image.file(
                              File(doc.imagePath),
                              width: 80,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            title: Text(doc.name),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
