import 'package:flutter/material.dart';

class MayTinh extends StatelessWidget {
  const MayTinh({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueGrey),
              child: Text("Calculator", style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text("Standard"),
              onTap: () => Navigator.pop(context), 
            ),
            ListTile(
              leading: const Icon(Icons.science),
              title: const Text("Scientific"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.graphic_eq),
              title: const Text("Graphing"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.design_services),
              title: const Text("Programmer"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text("Date calculation"),
              onTap: () => Navigator.pop(context),
            ),
            
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      
      appBar: AppBar(
       
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(20),
              child: const Text(
                "0",
                style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: Padding(padding: const EdgeInsets.all(1.0), child: ElevatedButton(style: ElevatedButton.styleFrom(shape: const RoundedRectangleBorder(), backgroundColor: Colors.white70), onPressed: () {}, child: const Text("%")))),
                        Expanded(child: Padding(padding: const EdgeInsets.all(1.0), child: ElevatedButton(style: ElevatedButton.styleFrom(shape: const RoundedRectangleBorder(), backgroundColor: Colors.white70), onPressed: () {}, child: const Text("CE")))),
                        Expanded(child: Padding(padding: const EdgeInsets.all(1.0), child: ElevatedButton(style: ElevatedButton.styleFrom(shape: const RoundedRectangleBorder(), backgroundColor: Colors.white70), onPressed: () {}, child: const Text("C")))),
                        Expanded(child: Padding(padding: const EdgeInsets.all(1.0), child: ElevatedButton(style: ElevatedButton.styleFrom(shape: const RoundedRectangleBorder(), backgroundColor: Colors.white70), onPressed: () {}, child: const Icon(Icons.backspace_outlined, size: 18)))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: Padding(padding: const EdgeInsets.all(1.0), child: ElevatedButton(style: ElevatedButton.styleFrom(shape: const RoundedRectangleBorder(), backgroundColor: Colors.white), onPressed: () {}, child: const Text("7")))),
                        Expanded(child: Padding(padding: const EdgeInsets.all(1.0), child: ElevatedButton(style: ElevatedButton.styleFrom(shape: const RoundedRectangleBorder(), backgroundColor: Colors.white), onPressed: () {}, child: const Text("8")))),
                        Expanded(child: Padding(padding: const EdgeInsets.all(1.0), child: ElevatedButton(style: ElevatedButton.styleFrom(shape: const RoundedRectangleBorder(), backgroundColor: Colors.white), onPressed: () {}, child: const Text("9")))),
                        Expanded(child: Padding(padding: const EdgeInsets.all(1.0), child: ElevatedButton(style: ElevatedButton.styleFrom(shape: const RoundedRectangleBorder(), backgroundColor: Colors.white70), onPressed: () {}, child: const Text("×")))),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: Padding(padding: const EdgeInsets.all(1.0), child: ElevatedButton(style: ElevatedButton.styleFrom(shape: const RoundedRectangleBorder(), backgroundColor: Colors.white), onPressed: () {}, child: const Text("4")))),
                        Expanded(child: Padding(padding: const EdgeInsets.all(1.0), child: ElevatedButton(style: ElevatedButton.styleFrom(shape: const RoundedRectangleBorder(), backgroundColor: Colors.white), onPressed: () {}, child: const Text("5")))),
                        Expanded(child: Padding(padding: const EdgeInsets.all(1.0), child: ElevatedButton(style: ElevatedButton.styleFrom(shape: const RoundedRectangleBorder(), backgroundColor: Colors.white), onPressed: () {}, child: const Text("6")))),
                        Expanded(child: Padding(padding: const EdgeInsets.all(1.0), child: ElevatedButton(style: ElevatedButton.styleFrom(shape: const RoundedRectangleBorder(), backgroundColor: Colors.white70), onPressed: () {}, child: const Text("-")))),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: Padding(padding: const EdgeInsets.all(1.0), child: ElevatedButton(style: ElevatedButton.styleFrom(shape: const RoundedRectangleBorder(), backgroundColor: Colors.white), onPressed: () {}, child: const Text("1")))),
                        Expanded(child: Padding(padding: const EdgeInsets.all(1.0), child: ElevatedButton(style: ElevatedButton.styleFrom(shape: const RoundedRectangleBorder(), backgroundColor: Colors.white), onPressed: () {}, child: const Text("2")))),
                        Expanded(child: Padding(padding: const EdgeInsets.all(1.0), child: ElevatedButton(style: ElevatedButton.styleFrom(shape: const RoundedRectangleBorder(), backgroundColor: Colors.white), onPressed: () {}, child: const Text("3")))),
                        Expanded(child: Padding(padding: const EdgeInsets.all(1.0), child: ElevatedButton(style: ElevatedButton.styleFrom(shape: const RoundedRectangleBorder(), backgroundColor: Colors.white70), onPressed: () {}, child: const Text("+")))),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: Padding(padding: const EdgeInsets.all(1.0), child: ElevatedButton(style: ElevatedButton.styleFrom(shape: const RoundedRectangleBorder(), backgroundColor: Colors.white), onPressed: () {}, child: const Text("+/-")))),
                        Expanded(child: Padding(padding: const EdgeInsets.all(1.0), child: ElevatedButton(style: ElevatedButton.styleFrom(shape: const RoundedRectangleBorder(), backgroundColor: Colors.white), onPressed: () {}, child: const Text("0")))),
                        Expanded(child: Padding(padding: const EdgeInsets.all(1.0), child: ElevatedButton(style: ElevatedButton.styleFrom(shape: const RoundedRectangleBorder(), backgroundColor: Colors.white), onPressed: () {}, child: const Text(".")))),
                        Expanded(child: Padding(padding: const EdgeInsets.all(1.0), child: ElevatedButton(style: ElevatedButton.styleFrom(shape: const RoundedRectangleBorder(), backgroundColor: Colors.blue, foregroundColor: Colors.white), onPressed: () {}, child: const Text("=")))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    )
    );
  }
}