import 'package:flutter/material.dart';
import 'package:jollofradio/config/strings/AppColor.dart';

class Stylesheet {
  static ThemeData lightTheme() {
    
    return ThemeData(
      /*
      * Define the primary color and brightness level for current theme
      */
      // colorSchemeSeed: (Color(0XFF343674) ),
      colorSchemeSeed: (Color(0XFF030F18)),
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColor.primary,
      
      // primarySwatch: Colors.deepPurple,
      // primaryColor: Color(0XFF182551'),

      /*
      * Define the font family to be used across the wholw application
      */
      fontFamily: 'Satoshi',

      /*
      * Define the default `appTheme`. Use this to specify the default
      * text styling for headlines, titles, bodies of text, and more..
      */
      appBarTheme: AppBarTheme  (
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Color(0XFFFFFFFF),
        ),

        titleTextStyle: TextStyle(
          fontSize: 18,
          color: Color(0XFFFFFFFF)
        ),
        backgroundColor: Colors.transparent,
        /*
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        titleTextStyle: TextStyle(
          color: Colors.white
        ),
        backgroundColor: Color   (0xFF343674),
        */
      ),

      /*
      * Define the default tex buttonThemeData:`. Use this to specify 
      * the default styling for flutter buttons: i.e [T,E,O] elements
      */
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: TextStyle(
            fontFamily: 'Satoshi',
          ),
          backgroundColor: Color(0XFFF0CF7B),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: TextStyle(
            color: Color(0XFF030F18),
            fontFamily: 'Satoshi',
          ),
          backgroundColor: Color(0XFFF0CF7B)
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: TextStyle(
            fontFamily: 'Satoshi',
          ),
          backgroundColor: Color(0XFFF0CF7B)
        ),
      ),

      /*
      * Define the default`TextTheme`. Use this to setup the default
      * text styling for headlines, titles, bodies of text, and more.
      */
      textTheme: const TextTheme(
        bodyLarge: TextStyle(),
        bodyMedium: TextStyle(),
        displayLarge: TextStyle(
          fontSize: 72.0, 
          fontWeight: FontWeight.bold
        ),
      ).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.white,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.transparent
      ),

      /*
      * Define the default `NavigationBarTheme:`. Use this to specify 
      * the default styling for navigationbar and selected menu items 
      */
      //Bottom Navigation
      navigationBarTheme: NavigationBarThemeData(
        height: 60,
        backgroundColor: Color(0XFF051724),
        indicatorColor: Color(0XFFFFFFFF),
        iconTheme: MaterialStateProperty.all(
          IconThemeData(
            color: Color(0XFFFFFFFF),
          ),
        ),
        labelTextStyle: MaterialStateProperty.all(
          TextStyle(
            color: Colors.black54,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'Satoshi',
          )
        )
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData  (
        elevation: 0,
        backgroundColor: Color(0XFF051724),
        type: BottomNavigationBarType.fixed,

        selectedIconTheme: IconThemeData(
          size: 20
        ),
        selectedItemColor: Colors.white,
        selectedLabelStyle: TextStyle(
          color: Color(0XFFFFFFFF), fontSize: 12.0 // styling label
        ),
        unselectedIconTheme: IconThemeData(
          size: 20
        ),
        unselectedItemColor: Color(0XFF575C5F),
        unselectedLabelStyle: TextStyle(
          color: Color(0XFF575C5F), fontSize: 12.0 // label styling
        )
      ),

      pageTransitionsTheme: PageTransitionsTheme(
        builders: 
          Map< TargetPlatform, PageTransitionsBuilder >.fromIterable(
          TargetPlatform.values, 
          value: (dynamic _) => FadeUpwardsPageTransitionsBuilder(  ),
        ),
      ),
    );
  }
  
}