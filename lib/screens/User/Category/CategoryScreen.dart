import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/models/Category.dart';
import 'package:jollofradio/config/models/User.dart';
import 'package:jollofradio/config/services/controllers/CategoryController.dart';
import 'package:jollofradio/config/services/providers/UserProvider.dart';
import 'package:jollofradio/config/strings/Message.dart';
import 'package:jollofradio/screens/Layouts/Templates/Category.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:provider/provider.dart';

class CategoryScreen extends StatefulWidget {
  final List categories;
  const CategoryScreen({super.key, required this.categories});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late User user;
  bool isLoading = true;
  List categories = [];

  @override
  void initState() {
    var auth = Provider.of<UserProvider>(context,listen: false);
    user = auth.user;

    // categories = widget.categories;

    getCategory();

    super.initState();
  }

  Future<void> getCategory() async {
    var category = widget.categories;

    if( category.isEmpty){
      category = await CategoryController.index(); //refreshing
    }

    categories = category;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Buttons.back(),
        title: Text("Podcast Category"),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: double.infinity,
        margin: EdgeInsets.only(
          top: 0,
          left: 20, 
          right: 20
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(isLoading) ...[
              Container(
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 2.6
                ),
                padding: EdgeInsets.fromLTRB(40, 20, 40, 10),
                child: Column(
                  children: <Widget>[
                    Center(
                      child: const CircularProgressIndicator(),
                    )
                  ],
                ),
              )
            ]
            else ...[
              Column(
                children: [
                  if(categories.isEmpty)
                    Container(
                      height: 300,
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 4
                      ),
                      padding: EdgeInsets.fromLTRB(40, 20, 40, 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Iconsax.document,
                            size: 40,
                            color: Color(0XFF9A9FA3),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            Message.no_data,
                            style: TextStyle(color: Color(0XFF9A9FA3),
                              fontSize: 14
                            ),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    )
                  else
                    FadeInUp(
                      child: GridView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 100 / 90,
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                        ),
                        physics: 
                        ScrollPhysics(parent: NeverScrollableScrollPhysics(  )),
                        itemCount: categories.length,
                        itemBuilder: (context, index){    
                          return Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: CategoryTemplate(
                              category: categories[index],
                              compact: true,
                            ),
                          );
                        }
                      ),
                    ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}