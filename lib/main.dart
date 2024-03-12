import 'package:flutter/material.dart';
import 'package:sqflight_demo/database.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQFlite Demo',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SQFlite Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: _titleController, decoration: InputDecoration(labelText: 'Title')),
            TextField(controller: _contentController, decoration: InputDecoration(labelText: 'Content')),
            ElevatedButton(
              onPressed: () async {
                await DatabaseHelper.instance.insert({
                  'title': _titleController.text,
                  'content': _contentController.text,
                });
                setState(() {});
                _titleController.clear();
                _contentController.clear();
              },
              child: Text('Add Note'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: DatabaseHelper.instance.queryAll(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(snapshot.data![index]['title']),
                        subtitle: Text(snapshot.data![index]['content']),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            await DatabaseHelper.instance.delete(snapshot.data![index]['id']);
                            setState(() {});
                          },
                        ),
                        onTap: (){
                          _showEditDialog(snapshot.data![index]);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _showEditDialog(Map<String, dynamic> note) async {
    TextEditingController titleController = TextEditingController(text: note['title']);
    TextEditingController contentController = TextEditingController(text: note['content']);

    Map<String, dynamic> updatedNote = {
      'id': note['id'],
      'title': note['title'],
      'content': note['content'],
    };

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
                decoration: InputDecoration(labelText: 'Content'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Update'),
              onPressed: () async {
                updatedNote['title'] = titleController.text;
                updatedNote['content'] = contentController.text;
                await DatabaseHelper.instance.update(updatedNote);
                setState(() {}); // Update the UI after editing
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

