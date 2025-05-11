import 'package:flutter/material.dart';
import 'package:foodscanner_2/screens/MoreScreen.dart';
import 'package:foodscanner_2/widgets/bottom_nav.dart';

class HomePageWork extends StatefulWidget {
  const HomePageWork({super.key});

  @override
  State<HomePageWork> createState() => _HomePageWorkState();
}

class _HomePageWorkState extends State<HomePageWork> {
  int _selectedIndex = 0;



  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return 
    BottomNavWithScanner(
      body: Scaffold(
        backgroundColor: Colors.white,
       
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Hello',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 30),
                        ),
                        Text(
                          'Guest,',
                          style: TextStyle(
                              fontSize: 30,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const CircleAvatar(radius: 30),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                TextFormField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Check Food...',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                const Text(
                  'Highest Scores...',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 18),
                ),
                SizedBox(height: screenHeight * 0.02),
                SizedBox(
                  height: 200,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        width: screenWidth * 0.4,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                const Text(
                  'Previous Scan...',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  
}
 
//
// void main() {
//   runApp(
//       DevicePreview(builder: (context)=> MyApp())
//   );
// }
// // // void main()=>runApp(MyApp());
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//           brightness: Brightness.dark
//       ),
//       debugShowCheckedModeBanner: false,
//       home: HomeScreen(),
//     );
//   }
// }