import 'package:flutter/material.dart';

class BaiTapStack extends StatelessWidget {
  const BaiTapStack({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
      
          backgroundColor: const Color.fromARGB(255, 239, 168, 4),
          leading: IconButton(onPressed: () {}, icon: const Icon(Icons.home)),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(40),
                image: const DecorationImage(
                  image: AssetImage('assets/images/dong_phong_nha.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: 20,
              left: 20,
              bottom: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                height: 150,
                child: const Column(
                  children: <Widget>[
                    SizedBox(height: 10),
                    Text(
                      "Động Phong Nha",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Động Phong Nha, nằm trong vườn quốc gia Phong Nha - Kẻ Bàng, tỉnh Quảng Ninh, Việt Nam, là một trong những hang động nổi tiếng và hấp dẫn nhất thế giới.",
                        maxLines: 4,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
