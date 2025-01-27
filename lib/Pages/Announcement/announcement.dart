import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/Models/Item.dart';
import 'package:my_app/Models/Announcement.dart';
import 'package:my_app/Pages/Announcement/announcement_item.dart';
import 'package:my_app/Pages/PostDonation/post_donation.dart';
import 'package:my_app/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;

class Listings extends StatefulWidget {
  static String routeName = "/Listings";
  @override
  _ListingsState createState() => _ListingsState();
}

class _ListingsState extends State<Listings> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<Announcement>> futureAnnouncements;
  var email = "";

  @override
  void initState() {
    super.initState();
    futureAnnouncements = getAnnouncements();
    preLoad();
  }

  void preLoad() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email');
    });
    getUserDetails();
  }

  void getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    http.Response response =
        await http.post("https://foodernity.herokuapp.com/user/getUserDetails",
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'email': email,
            }));
    print(response.body + 'from listing');
    Map<String, dynamic> map = json.decode(response.body);
    print("Dissected in listings page");
    print(map["userID"]);
    print(map["email"]);
    print(map["password"]);
    print(map["dateOfReg"]);
    print(map["loginMethod"]);

    prefs.setInt('userID', map["userID"]);
    prefs.setString('email', map["email"]);
    prefs.setString('password', map["password"]);
    prefs.setString('fullName', map["fullName"]);
    prefs.setString('profilePicture', map["profilePicture"]);
    prefs.setString('dateOfReg', map["dateOfReg"]);
    prefs.setString('loginMethod', map["loginMethod"]);
    prefs.setString('userType', map["userType"]);
    prefs.setString('userStatus', map["userStatus"]);
    prefs.setString('changePasswordCode', map["changePasswordCode"]);
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return WillPopScope(
        onWillPop: () {
          return showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text('Warning',
                        style: TextStyle(color: Colors.redAccent)),
                    content: Text('Are you sure to Exit ?'),
                    actions: <Widget>[
                      FlatButton(
                          onPressed: () => SystemNavigator.pop(),
                          child: Text('Yes')),
                      FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text('No'))
                    ],
                  ));
        },
        child: Scaffold(
          key: scaffoldKey,
          body: Container(
            color: Colors.grey[200],
            height: 100.h,
            width: 100.w,
            child: SafeArea(
              child: Container(
                child: FutureBuilder(
                  future: futureAnnouncements,
                  builder: (context, snapshot) {
                    Widget announcementsSliverList;
                    if (snapshot.hasData) {
                      announcementsSliverList = SliverList(
                        delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                          return AnnouncementItem(
                              announcement: snapshot.data[index]);
                        }, childCount: snapshot.data.length),
                      );
                    } else {
                      announcementsSliverList = SliverToBoxAdapter(
                        child: Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    }
                    return CustomScrollView(
                      slivers: [
                        CupertinoSliverNavigationBar(
                          automaticallyImplyLeading: false,
                          largeTitle: Text('Announcements'),
                        ),
                        _recentDonations(),
                        announcementsSliverList
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Navigator.pushNamed(context, AddListing.routeName);
              showInformationDialog(context);
            },
            child: Icon(Icons.add),
            backgroundColor: ColorPrimary,
          ),
        ),
      );
    });
  }
}

List<Item> agreementItems = [
  Item(
    headerValue:
        'I acknowledge that I am donating foods that are in the following:',
    expandedValue:
        'Canned Goods - Canned fruits and vegetables, milks and sauces, meat and fish.',
    expandedValue2:
        'Instant Noodles - Instant Noodles sush as soups noodles, fried noodles, non-fried noodles.',
    expandedValue3:
        'Snacks & Biscuits - Any kinds of snacks and biscuits and the.',
    expandedValue4:
        'Beverages - Water, tea, coffee, soft drinks, juice drinks (alcoholic are prohibited).',
    expandedValue5:
        "Others - Other non-perishable foods that don't require refrigeration (e.g., condiments).",
    expandedValue6: '',
  ),
  Item(
    headerValue:
        'I acknowledge that I am not donating foods that are in the following:',
    expandedValue:
        'Home-cooked-foods - Foods prepared, cooked, cooled, or reheated at home.',
    expandedValue2:
        'Expired Foods - Foods that are past a "use by / consume by" date.',
    expandedValue3:
        'Foods in containers - Foods taken out of their original packaging and placed into containers.',
    expandedValue4:
        'Opened Foods - Foods in opened or torn containers exposing the food to potential contamination.',
    expandedValue5:
        "Raw foods - Meat, beef, pork, poultry, and other considered raw foods.",
    expandedValue6:
        "Others - Other perishables such as fruits, vegetables, dairy products, eggs, meat, poultry, and seafood.",
  ),
  Item(
    headerValue:
        'I acknowledge that I am donating foods that are in the following:',
    expandedValue:
        'Canned Goods - Canned fruits and vegetables, milks and sauces, meat and fish.',
    expandedValue2:
        'Instant Noodles - Instant Noodles sush as soups noodles, fried noodles, non-fried noodles.',
    expandedValue3:
        'Snacks & Biscuits - Any kinds of snacks and biscuits and the.',
    expandedValue4:
        'Beverages - Water, tea, coffee, soft drinks, juice drinks (alcoholic are prohibited).',
    expandedValue5:
        "Others - Other non-perishable foods that don't require refrigeration (e.g., condiments).",
    expandedValue6: '',
  ),
  Item(
    headerValue:
        'I acknowledge that I am not donating foods that are in the following:',
    expandedValue:
        'Home-cooked-foods - Foods prepared, cooked, cooled, or reheated at home.',
    expandedValue2:
        'Expired Foods - Foods that are past a "use by / consume by" date.',
    expandedValue3:
        'Foods in containers - Foods taken out of their original packaging and placed into containers.',
    expandedValue4:
        'Opened Foods - Foods in opened or torn containers exposing the food to potential contamination.',
    expandedValue5:
        "Raw foods - Meat, beef, pork, poultry, and other considered raw foods.",
    expandedValue6:
        "Others - Other perishables such as fruits, vegetables, dairy products, eggs, meat, poultry, and seafood.",
  ),
  Item(
    headerValue:
        'I acknowledge that I am donating foods that are in the following:',
    expandedValue:
        'Canned Goods - Canned fruits and vegetables, milks and sauces, meat and fish.',
    expandedValue2:
        'Instant Noodles - Instant Noodles sush as soups noodles, fried noodles, non-fried noodles.',
    expandedValue3:
        'Snacks & Biscuits - Any kinds of snacks and biscuits and the.',
    expandedValue4:
        'Beverages - Water, tea, coffee, soft drinks, juice drinks (alcoholic are prohibited).',
    expandedValue5:
        "Others - Other non-perishable foods that don't require refrigeration (e.g., condiments).",
    expandedValue6: '',
  ),
];

Future<void> showInformationDialog(BuildContext context) async {
  var size = MediaQuery.of(context).size;
  final double height = (size.height) / 2.0;
  final double width = size.width / 1;
  final List<Item> _data = agreementItems;
  const description =
      "Before proceeding to post a donation, you must adhere to the guidelines first to protect you and the safety of the others as we. The guidelines to acknowledge are as follows.";

  return await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Container(
                height: height,
                width: width,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text('Guidelines For Donating',
                            style: TextStyle(color: Colors.blue)),
                      ),
                      SizedBox(
                        height: 3.0,
                      ),
                      Text(description,
                          style: TextStyle(
                            fontSize: 11.sp,
                          )),
                      SizedBox(
                        height: 30,
                      ),
                      ExpansionPanelList(
                        expansionCallback: (int index, bool isExpanded) {
                          setState(() {
                            _data[index].isExpanded = !isExpanded;
                          });
                        },
                        children: _data.map<ExpansionPanel>((Item item) {
                          return ExpansionPanel(
                            headerBuilder:
                                (BuildContext context, bool isExpanded) {
                              return ListTile(
                                title: Text(
                                  item.headerValue,
                                  style: TextStyle(fontSize: 12.0),
                                ),
                              );
                            },
                            body: ListTile(
                              title: Column(
                                children: [
                                  Text(item.expandedValue,
                                      style: TextStyle(fontSize: 10.sp)),
                                  SizedBox(height: 10.0),
                                  Text(item.expandedValue2,
                                      style: TextStyle(fontSize: 10.0)),
                                  SizedBox(height: 10.0),
                                  Text(item.expandedValue3,
                                      style: TextStyle(fontSize: 10.0)),
                                  SizedBox(height: 10.0),
                                  Text(item.expandedValue4,
                                      style: TextStyle(fontSize: 10.0)),
                                  SizedBox(height: 10.0),
                                  Text(item.expandedValue5,
                                      style: TextStyle(fontSize: 10.0)),
                                  SizedBox(height: 10.0),
                                  Text(item.expandedValue6,
                                      style: TextStyle(fontSize: 10.0)),
                                ],
                              ),
                            ),
                            isExpanded: item.isExpanded,
                          );
                        }).toList(),
                      )
                    ],
                  ),
                )),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child: Text(
                        "Close",
                      )),
                  FlatButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PostDonation()));
                    },
                    child:
                        Text("Proceed", style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            ],
          );
        });
      });
}

class InventoryContainer extends StatelessWidget {
  const InventoryContainer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// Widget _Inventory(context) {
//   int _index;
//   var width = MediaQuery.of(context).size.width - 200;
//   var height = MediaQuery.of(context).size.height / 7;
//   final categories = [
//     "Eggs",
//     "Canned goods",
//     "Instant Noodles",
//     "Rice",
//     "Cereals",
//     "Tea, Coffee, Milk, Sugar, etc.",
//     "Biscuits",
//     "Condiments and sauces",
//     "Beverages",
//     "Snacks",
//   ];
//   final image = [
//     'assets/images/eggs.png',
//     'assets/images/canned-food.png',
//     'assets/images/instant-noodles.png',
//     'assets/images/canned-food.png',
//     'assets/images/bakery.png',
//     'assets/images/canned-food.png',
//     'assets/images/snack.png',
//     'assets/images/canned-food.png',
//     'assets/images/snack.png',
//     'assets/images/snack.png',
//   ];

//   final stocks = ['40', '50', '60', '70', '80', '20', '10', '5', '23', '16'];
//   return Container(
//     child: Center(
//       child: SizedBox(
//           // height: 120, // card height
//           height: height,
//           // width: width,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: categories.length,
//             itemBuilder: (context, index) {
//               return Container(
//                 width: width,
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Card(
//                     elevation: 2,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(5)),
//                     child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Wrap(
//                           direction: Axis.vertical,
//                           children: [
//                             Row(
//                               children: [
//                                 Image(image: AssetImage(image[index])),
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Column(
//                                     children: [
//                                       SizedBox(
//                                         width: 120,
//                                         child: Text(
//                                           categories[index],
//                                           style: TextStyle(fontSize: 14),
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding:
//                                             const EdgeInsets.only(top: 10.0),
//                                         child: Text(
//                                           stocks[index],
//                                           style: TextStyle(
//                                               fontSize: 20,
//                                               fontWeight: FontWeight.bold),
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         )),
//                   ),
//                 ),
//               );
//             },
//           )),
//     ),
//   );
// }

// Widget _filter(context) {
//   return (Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       GestureDetector(
//         onTap: () {
//           showModalBottomSheet(
//               context: context,
//               builder: (BuildContext context) {
//                 return _filterPicker();
//               });
//         },
//         child: Row(
//           children: [Text('Available Now'), Icon(Icons.arrow_drop_down)],
//         ),
//       ),
//       TextButton(
//           onPressed: () {
//             showModalBottomSheet(
//                 context: context,
//                 builder: (BuildContext context) {
//                   return (_filterSheet());
//                 });
//           },
//           child: Text('FILTER')),
//     ],
//   ));
// }

// Widget _filterPicker() {
//   return Container(
//     height: 250.0,
//     child: (CupertinoPicker(
//       useMagnifier: true,
//       onSelectedItemChanged: (index) {},
//       itemExtent: 50.0,
//       backgroundColor: Colors.white,
//       children: [
//         Center(child: Text('Available Now')),
//         Center(child: Text('Suggested')),
//         Center(child: Text('Nearest')),
//       ],
//     )),
//   );
// }

// Widget _filterSheet() {
//   return Container(
//     height: 500.0,
//     child: (Column(
//       children: [
//         Text('My Location'),
//         ListTile(
//           leading: Icon(
//             Icons.location_on_rounded,
//           ),
//           title: Text('Bali Oasis, Pasig'),
//           trailing: Icon(Icons.edit_rounded),
//         )
//       ],
//     )),
//   );
// }

// Widget _currentStocks() {
//   return Padding(
//     padding: const EdgeInsets.only(top: 10.0),
//     child: (Text(
//       'MHTP Current Stocks',
//       style: TextStyle(
//           fontWeight: FontWeight.bold, fontSize: 18.0, color: Colors.blue),
//     )),
//   );
// }

Widget _recentDonations() {
  return SliverToBoxAdapter(
    child: Container(
      margin: EdgeInsets.only(left: 15, top: 10, bottom: 5),
      child: (Text(
        'Recent Donations from Donors',
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 18.0, color: Colors.blue),
      )),
    ),
  );
}

class RecentDonations extends StatefulWidget {
  const RecentDonations({Key key}) : super(key: key);

  @override
  _RecentDonationsState createState() => _RecentDonationsState();
}

class _RecentDonationsState extends State<RecentDonations> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double height = (size.height) - 29.h;
    return SliverToBoxAdapter(
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return Container(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            height: height,
            child: FutureBuilder(
              future: getAnnouncements(),
              builder: (context, snapshot) {
                Widget announcementsSliverList;
                if (snapshot.hasData) {
                  announcementsSliverList = SliverList(
                    delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      return AnnouncementItem();
                    }),
                  );
                } else {
                  announcementsSliverList = SliverToBoxAdapter(
                    child: Container(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return CustomScrollView(
                  slivers: [announcementsSliverList],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

Future<List<Announcement>> getAnnouncements() async {
  print('get announcements');

  final response = await http.post(
      Uri.parse(
          "https://foodernity.herokuapp.com/donations/getDistributedDonations"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{}));

  List<Announcement> parsedAnnouncements = [];

  if (response.statusCode == 200) {
    List announcements = jsonDecode(response.body);

    for (var announcement in announcements) {
      announcement['donationCategory'] =
          announcement['donationCategory'].toString().split(',');
      announcement['donationQuantity'] =
          announcement['donationQuantity'].toString().split(',');

      parsedAnnouncements.add(Announcement.fromJSON(announcement));
    }
  }

  return parsedAnnouncements;
}



// class ListingsContainer extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     final double itemHeight = (size.height) / 6.5;
//     final double itemWidth = size.width / 2;
//     return SliverPadding(
//       // padding: EdgeInsets.symmetric(horizontal: 20.0),
//       padding:
//           EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0, bottom: 15.0),
//       sliver: (SliverGrid.count(
//         childAspectRatio: (itemWidth / itemHeight),
//         crossAxisSpacing: 5.0,
//         mainAxisSpacing: 5.0,
//         crossAxisCount: 1,
//         children: [
//           _listingItem(
//               'Donation Drive to the residents of Barangay 403 ',
//               'November 05, 2021',
//               'https://psu.edu.ph/wp-content/uploads/2020/11/125760987_1831764043637981_8035397335388690116_n.jpg',
//               context),
//           _listingItem(
//               'Donation Drive to the residents of Barangay 403',
//               'November 05, 2021',
//               'http://static1.squarespace.com/static/55f9afdfe4b0f520d4e4ff43/55f9b97fe4b0241b81b0cbe4/5eb092883c9e9c74eb3c23fa/1594661924914/OC+AOT+food+donation.jpg?format=1500w',
//               context),
//           _listingItem(
//               'Donation Drive to the residents of Barangay 403',
//               'November 05, 2021',
//               'https://psu.edu.ph/wp-content/uploads/2020/11/125760987_1831764043637981_8035397335388690116_n.jpg',
//               context),
//         ],
//       )),
//     );
//   }
// }

// Widget _listingItem(title, date, image, context) {
//   var donationImage = image;
//   var donationDate = date;
//   var donationTitle = title;

//   var width = MediaQuery.of(context).size.width;
//   var height = MediaQuery.of(context).size.height / 5;

//   return InkWell(
//     splashColor: Colors.blue.withAlpha(30),
//     onTap: () {
//       Navigator.push(
//           context, MaterialPageRoute(builder: (context) => ListingDetails()));
//     },
//     child: (Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(4.0),
//             child: Image(
//               fit: BoxFit.fitWidth,
//               height: height,
//               width: double.infinity,
//               image: NetworkImage(donationImage),
//             ),
//           ),
//           Container(
//             child: Padding(
//               padding: const EdgeInsets.only(left: 8.0),
//               child: Column(
//                 children: [
//                   ListTile(
//                     title: Text(
//                       donationDate,
//                       style:
//                           TextStyle(fontWeight: FontWeight.w300, fontSize: 12),
//                     ),
//                     subtitle: Text(
//                       donationTitle,
//                       style: TextStyle(
//                           fontWeight: FontWeight.w600,
//                           fontSize: 14.0,
//                           color: Colors.grey[600]),
//                     ),
//                     trailing: Wrap(
//                       spacing: 1,
//                       children: <Widget>[
//                         Icon(Icons.navigate_next_sharp, color: Colors.blue)
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     )),
//   );
// }

