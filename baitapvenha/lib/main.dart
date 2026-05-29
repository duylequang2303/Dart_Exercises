import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

////////////////////////////////////////////////////////
/// DATA
////////////////////////////////////////////////////////

List<Map<String, dynamic>> products = [
  {
    "name": "Điện thoại 01",
    "price": 10000000,
    "image": "assets/images/ipad-pro-m4-13-inch-wifi-cellular-mat-kinh-nano-hinh-1.jpg"
  },
  {
    "name": "Điện thoại 04",
    "price": 12000000,
    "image": "assets/images/iphone-15-pro-max-p1.jpg"
  },
  {
    "name": "Điện thoại 07",
    "price": 20000000,
    "image": "assets/images/iphone-17-pro-1.jpg"
  },
];

List<Map<String, dynamic>> cart = [];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Shop",
      home: IntroPage(),
    );
  }
}

class IntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Image.asset("assets/images/images.png", width: 120, height: 120),

            SizedBox(height:20),

            Text(
              "Cửa hàng điện thoại",
              style: TextStyle(fontSize:24,fontWeight:FontWeight.bold),
            ),

            SizedBox(height:10),

            Text("140 Lê Trọng Tấn, Tân Phú, TP.HCM"),

            SizedBox(height:40),

            ElevatedButton(
              child: Icon(Icons.arrow_forward),
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder:(context)=>StorePage()),
                );
              },
            )

          ],
        ),
      ),
    );
  }
}


class StorePage extends StatefulWidget {
  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {

  void addProduct(Map<String,dynamic> product){

    showDialog(
      context: context,
      builder:(context){
        return AlertDialog(
          title: Text("Xác nhận"),
          content: Text("Bạn vừa thêm sản phẩm vào Giỏ hàng"),
          actions: [

            TextButton(
              child: Text("Không"),
              onPressed: (){
                Navigator.pop(context);
              },
            ),

            TextButton(
              child: Text("Đồng ý"),
              onPressed: (){
                setState(() {
                  cart.add(product);
                });
                Navigator.pop(context);
              },
            )

          ],
        );
      },
    );

  }

  Drawer drawerMenu(){
    return Drawer(
      child: ListView(
        children: [

          UserAccountsDrawerHeader(
            accountName: Text("Trần Minh Phúc"),
            accountEmail: Text("tranminhphuc11a4@gmail.com"),
            currentAccountPicture: CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),

          ListTile(
            leading: Icon(Icons.store),
            title: Text("Cửa hàng"),
            onTap: (){
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text("Giỏ hàng"),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder:(context)=>CartPage()),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text("Thoát"),
            onTap: (){
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder:(context)=>IntroPage()),
                (route)=>false,
              );
            },
          ),

        ],
      ),
    );
  }

  Widget productCard(Map<String,dynamic> product){
    return Card(
      elevation:10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding:EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Image.asset(
              product["image"],
              height:280,
              fit:BoxFit.contain,
            ),

            SizedBox(height:10),

            Text(
              product["name"],
              style:TextStyle(
                fontWeight:FontWeight.bold,
                fontSize:18,
              ),
            ),

            SizedBox(height:5),

            Text(
              product["price"].toString(),
              style:TextStyle(fontSize:16),
            ),

            SizedBox(height:10),

            ElevatedButton(
              style:ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7ED7C1),
                shape:RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: (){
                addProduct(product);
              },
              child: Icon(Icons.add,color:Colors.black),
            )

          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context){

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(
          "Cửa hàng điện thoại",
          style: TextStyle(color:Colors.black),
        ),
        iconTheme: IconThemeData(color:Colors.black),
        actions: [

          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder:(context)=>CartPage()),
              );
            },
          )

        ],
      ),

      drawer: drawerMenu(),

      body: Padding(
        padding:EdgeInsets.all(10),
        child: GridView.count(
          crossAxisCount:2,
          crossAxisSpacing:10,
          mainAxisSpacing:10,
          childAspectRatio:0.75,
          children: products.map((p)=>productCard(p)).toList(),
        ),
      ),

    );
  }
}

class CartPage extends StatefulWidget {
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {

  void removeProduct(int index){

    showDialog(
      context: context,
      builder:(context){
        return AlertDialog(
          title: Text("Xác nhận"),
          content: Text("Bạn muốn loại bỏ sản phẩm này ra khỏi giỏ hàng"),
          actions: [

            TextButton(
              child: Text("Không"),
              onPressed: (){
                Navigator.pop(context);
              },
            ),

            TextButton(
              child: Text("Đồng ý"),
              onPressed: (){
                setState(() {
                  cart.removeAt(index);
                });
                Navigator.pop(context);
              },
            )

          ],
        );
      },
    );

  }

  void checkout(){

    showDialog(
      context: context,
      builder:(context){
        return AlertDialog(
          title: Text("Thanh toán"),
          content: Text("Bạn đã thanh toán xong giỏ hàng"),
        );
      },
    );

    setState(() {
      cart.clear();
    });

  }

  @override
  Widget build(BuildContext context){

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(
          "Giỏ hàng của bạn",
          style: TextStyle(color:Colors.black),
        ),
        iconTheme: IconThemeData(color:Colors.black),
      ),

      body: cart.isEmpty
      ? Center(
        child: Text("Bạn chưa có sản phẩm nào trong giỏ hàng!!!"),
      )

      : ListView.builder(
        itemCount: cart.length,
        itemBuilder:(context,index){

          return ListTile(
            title: Text(cart[index]["name"]),
            subtitle: Text(cart[index]["price"].toString()),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: (){
                removeProduct(index);
              },
            ),
          );

        },
      ),

      bottomNavigationBar: Padding(
        padding:EdgeInsets.all(10),
        child: ElevatedButton(
          child: Text("Thanh toán"),
          onPressed: checkout,
        ),
      ),

    );
  }
}