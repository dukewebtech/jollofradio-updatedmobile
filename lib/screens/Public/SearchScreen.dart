import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/services/controllers/CategoryController.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/screens/Layouts/Templates/Category.dart';
import 'package:jollofradio/utils/helpers/Cache.dart';
import 'package:jollofradio/utils/helpers/Factory.dart';
import 'package:jollofradio/widget/Input.dart';
import 'package:jollofradio/widget/Labels.dart';
// import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  final Function(int page)? tabController;
  const SearchScreen(this.tabController, {super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // late User user;
  bool isLoading = true;
  List categories = [];
  TextEditingController search = TextEditingController();
  CacheStream cacheManager = CacheStream();

  @override
  void initState() {
    /*
    var auth = Provider.of<UserProvider>(context,listen: false);
    user = auth.user;
    */

    //cache manager
    (() async {
      await cacheManager.mount({
        'category': {
          'data': () async {
            return await CategoryController.index();
          },
          'rules': (data) => data.isNotEmpty,
        }
      }, null);

      getCategory();

    }());
    
    super.initState();
  }

  Future<void> getCategory() async {
    final category = await cacheManager.stream( ///////////////
      'category', 
      fallback: () async {
        return CategoryController.index();
      },
      callback: CategoryController.construct
    );

    category.shuffle();
    // categories = Factory(category).get(0,8);
    categories = category;
    
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: double.infinity,
        margin: EdgeInsets.only(
          top: AppBar().preferredSize.height + 00,
          left: 20, 
          right: 20
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Input.primary(
                  "What do you want to listen to?",
                  leadingIcon: Iconsax.search_normal,
                  controller: search,
                  onSubmit: (value){
                    if(value.isNotEmpty)
                    RouteGenerator.goto(SEARCH_PAGE, {
                      "query": value
                    });
                  }
                ),
                Positioned(
                  right: 5,
                  child: IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: () {
                      if(search.text.isNotEmpty)
                      RouteGenerator.goto(SEARCH_PAGE, {
                        "query": search.text
                      });
                    }, 
                    icon: Icon(
                      Iconsax.arrow_right_1,
                      size: 18,
                      color: Colors.white30,
                    )
                  ),
                )
              ],
            ),
            SizedBox(height: 10),
            Labels.primary(
              "Browse Categories",
              fontSize: 18,
              fontWeight: FontWeight.bold
            ),
            SizedBox(height: 10),
            if(isLoading) ...[
              Container(
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 4.2
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
              Expanded(
                child: SingleChildScrollView(
                  child: FadeIn(
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
                          child: CategoryTemplate(category: categories[index]),
                        );
                      }
                    ),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}