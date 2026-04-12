import 'package:flutter/material.dart';

class THTT extends StatefulWidget{
  const THTT({super.key});

  @override
  State<THTT> createState() => _THTT();
  
}

class _THTT extends State<THTT>{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.blue[800],
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(color: Colors.blue[600], borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(Icons.notifications, color: Colors.white),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                decoration: BoxDecoration(color: Colors.blue[600], borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(12),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.white,),
                    SizedBox(width: 5),
                    Text("Search", style: TextStyle(color: Colors.white),)
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text("How do you feel?", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(children: [Text("☹️"), Text("Bad", style: TextStyle(color: Colors.white))]),
                Column(children: [Text("😊"), Text("Fine", style: TextStyle(color: Colors.white))]),
                Column(children: [Text("😇"), Text("Well", style: TextStyle(color: Colors.white))]),
                Column(children: [Text("🥳"), Text("Excellent", style: TextStyle(color: Colors.white))]),
              ],
            ),
            const SizedBox(height: 25,),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(40),topRight: Radius.circular(40))
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Exercises", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                        Icon(Icons.more_horiz),
                      ],
                    ),
                    const SizedBox(height: 25,),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
                      child: const Row(
                        children: [
                          Icon(Icons.favorite, color: Colors.orange,),
                          SizedBox(width: 12,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Speaking Skills", style: TextStyle(fontWeight: FontWeight.bold),),
                              Text("16 Exercises", style: TextStyle(color: Colors.grey),)
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),

        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.message), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: '')
          ],
        ),
      ),
    );
  }

}