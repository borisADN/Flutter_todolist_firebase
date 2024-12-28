import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:planit/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PLAN IT',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'PLAN IT'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final CollectionReference _todos =
      FirebaseFirestore.instance.collection('todos');

  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: SafeArea(
            child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Ajouter une nouvelle tache',
                border: OutlineInputBorder(
                    // borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                suffixIcon: IconButton(
                    onPressed: () {
                      _todos.add({'task': _controller.text, 'done': false});
                      _controller.clear();
                    },
                    icon: Icon(Icons.add)),
                // labelText: 'Taches',
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: _todos.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView(
                        children: snapshot.data!.docs.map((doc) {
                      return ListTile(
                          onLongPress: () => _todos.doc(doc.id).delete(),
                          title: Text(doc['task'],
                              style: TextStyle(
                                  decoration: doc['done']
                                      ? TextDecoration.lineThrough
                                      : null)),
                          trailing: Checkbox(
                              value: doc['done'],
                              onChanged: (value) {
                                _todos.doc(doc.id).update({'done': value});
                              }));
                    }).toList());
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator.adaptive());
                  } else {
                    return const Center(
                      child: Text('No data found'),
                    );
                  }
                }),
          )
        ])));
  }
}
