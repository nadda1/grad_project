import 'package:flutter/material.dart';
import 'package:grad_project/profile.dart';

Container Jobs(String imagePath,String title){
  return Container(
    width: 200.0,
    child: Card(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              "assets/images/" + imagePath, // Add '/' to the end of the path
              height: 60.0,
            ),
            SizedBox(height: 10.0),
            Text(
              title,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}



class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
          backgroundColor: Color(0xFFEDF2FB),

          elevation: 2.0,
          leading: Row(

            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),

            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.more_horiz, color: Color(0xFF343ABA), size: 32.0),
              onPressed: () {},
            ),

          ],
           // This will remove the back button

        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start
        children: [
          SizedBox(height: 50.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 17),
            child: Text(
              'Find Your Job ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF343ABA),
              ),
            ),
          ),

          Container(
            margin: EdgeInsets.all(17),
            padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
            decoration: BoxDecoration(
              color: Color(0xFF5C8EF2),
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search',
                          prefixIcon: Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),


          Container(
            margin:EdgeInsets.symmetric(vertical: 15.0),
            height:150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children:<Widget> [
                Jobs("coffee.png","Baresta"),
                Jobs("delivery-man.png","Delivery"),
                Jobs("baby.png","Babysitting"),
                Jobs("cooking.png","cook"),
              ],
            ),
          ),
          Expanded(
            child: Container(
              // Add your JobsList widget here
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFFF1F5FC),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.home,color: Color(0xFF343ABA)),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.add,color: Color(0xFF343ABA)),
              onPressed: () {},
            ),
           
            IconButton(
            icon: Icon(Icons.account_circle_outlined, color: Color(0xFF343ABA)),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
            },
          ),

          ],
        ),
      ),

    );
  }
}
