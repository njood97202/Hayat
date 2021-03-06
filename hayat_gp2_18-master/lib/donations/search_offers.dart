import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hayat_gp2_18/donations/filter_loc.dart';
import 'package:hayat_gp2_18/donations/offer_details.dart';
import 'package:hayat_gp2_18/home_pages/charity_home.dart';
import 'package:hayat_gp2_18/home_pages/charity_home_2.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:geolocator/geolocator.dart';

class ListOffersPage3 extends StatefulWidget {
  var myArray;
  var myArray2S;
  var myArray2C;
  var Cid;
  var apply;
  var AllCategory;
  var SelectCategory;
  var selectstatus;
  var locationF;
  var getlocation1;
  ListOffersPage3(
      {Key? key,
      this.myArray,
      this.apply,
      this.AllCategory,
      this.myArray2S,
      this.myArray2C,
      this.selectstatus,
      this.SelectCategory,
      this.Cid,
      this.locationF,
      this.getlocation1})
      : super(key: key);
  @override
  _ListOffersPage3 createState() => _ListOffersPage3(
      myArray,
      apply,
      AllCategory,
      myArray2S,
      myArray2C,
      selectstatus,
      SelectCategory,
      Cid,
      locationF,
      getlocation1);
}

class _ListOffersPage3 extends State<ListOffersPage3> {
  List<ParseObject> allOffers = <ParseObject>[];
  var myArray;
  var apply;
  var AllCategory;
  var myArray2S;
  var myArray2C;
  var SelectCategory;
  var selectstatus;
  var Cid;
  var locationF;
  var getlocation1;
  List<ParseObject> Charity = <ParseObject>[];
  List<ParseObject> alldonations = <ParseObject>[];
  List<ParseObject> donor = <ParseObject>[];
  List<String> foundDonors = <String>[];
  List foundDonorsSorted = [];
  List Sorted = [];

  List<double> distancesList = <double>[];
  List distancesListSorted = [];
  double distance = 0.0;

  final Set<Marker> donorMarkerLocs = new Set();

  late GoogleMapController mapController; //contrller for Google map
  final Set<Marker> markers = new Set(); //markers for google map

  _ListOffersPage3(
      this.myArray,
      this.apply,
      this.AllCategory,
      this.myArray2S,
      this.myArray2C,
      this.selectstatus,
      this.SelectCategory,
      this.Cid,
      this.locationF,
      this.getlocation1);
  // late String searchText = searchController.text;
  //late var allOffers = [];
  var items = [];
  var match = [];
  var getlocation = [];
  var test = [];

  TextEditingController searchController = new TextEditingController();
  late String Searchstring = "";
  @override
  void initState() {
    super.initState();

    getOffers();
  }

  void getCHOs() async {
    QueryBuilder<ParseUser> queryUsers =
        QueryBuilder<ParseUser>(ParseUser.forQuery())
          ..whereEqualTo("objectId", Cid);

    final ParseResponse apiResponse = await queryUsers.query();

    if (apiResponse.success && apiResponse.results != null) {
      setState(() {
        Charity = apiResponse.results as List<ParseObject>;
        print('cho');
        print(Charity);
        print(Charity[0].get("name").toString());
        print(Charity[0].get("long"));
        print(Charity[0].get("lat"));
      });
      //add charity marker
      setState(() {
        markers.add(Marker(
          //add first marker

          markerId: MarkerId(Charity[0].get("name").toString()),
          position: LatLng(Charity[0].get("lat"),
              Charity[0].get("long")), //position of marker
          infoWindow: InfoWindow(
            //popup info
            title: 'Marker ' + Charity[0].get("name").toString(),
          ),
          icon: BitmapDescriptor.defaultMarker, //Icon for Marker
        ));
        print('marker added');
      });
      print('charity marker added');
    } else {
      Charity = [];
    }
    print('cho');
    print(Charity);
  }

  void getOffers() async {
    print('\n getlocation array is here \n');
    print(getlocation);
    QueryBuilder<ParseObject> parseQuery =
        QueryBuilder<ParseObject>(ParseObject('donations'))
          ..whereEqualTo("req_donation_status", 'Sent');

    final ParseResponse apiResponse = await parseQuery.query();

    if (apiResponse.success && apiResponse.results != null) {
      setState(() {
        allOffers = apiResponse.results as List<ParseObject>;
        items = allOffers;
        for (int i = 0; i < allOffers.length; i++) {
          //  var todyDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

          var offer = allOffers[i];
          DateTime? dbOfferDate = DateTime.parse(offer.get("exp_date"));

          print('tody date');
          print(DateTime.now());
          print('offer date');
          print(dbOfferDate);
          print('all donations');
          print(allOffers.length);

          if (dbOfferDate.isBefore(DateTime.now())) {
            items.remove(offer);
            allOffers.remove(offer);
            print("old remove");
          }
        }
      });
      search("", apply, myArray, locationF, getlocation1);
    } else {
      allOffers = [];
    }
    print(items);
  }

  void arrangment() async {
    // distancesList.sort();
    var smallestValue = distancesList[0];
    var indexx;
    var smallestdonor = foundDonors[0];

    //extract the first nearest distance

//extract the first nearest distance
    for (int i = 0; i < foundDonors.length; i++) {
      print('foundDonors');
      print(foundDonors);
      print(' distancesList.length');
      print(distancesList.length);
      for (int j = 0; j < distancesList.length; j++) {
        for (int z = 0; z < distancesList.length; z++) {
          if (distancesList[z] < distancesList[j] &&
              !distancesListSorted.contains(distancesList[z])) {
            setState(() {
              smallestValue = distancesList[z];
              smallestdonor = foundDonors[z];
              indexx = z;
            });
          }
          //foundDonors.remove(smallestValue);

          /*   if (1 == distancesList.length) {
            setState(() {
              smallestValue = distancesList[z];
            });
            smallestdonor = foundDonors[z];
          }*/
        }
      }
      if (i != distancesList.length - 1) {
        distancesListSorted.add(smallestValue);
        foundDonorsSorted.add(foundDonors[indexx]);
      } else {
        for (int i = 0; i < distancesList.length; i++) {
          if (!distancesListSorted.contains(distancesList[i])) {
            distancesListSorted.add(distancesList[i]);
          }
        }
        for (int i = 0; i < foundDonors.length; i++) {
          if (!foundDonorsSorted.contains(foundDonors[i])) {
            foundDonorsSorted.add(foundDonors[i]);
          }
        }
      }

      print(' distancesListSorted');
      print(distancesListSorted);
      print(' foundDonorsSorted');
      print(foundDonorsSorted);
    }
    filterLocation();
  }

  filterLocation() async {
    print(' in filter location foundDonorsSorted');
    print(foundDonorsSorted);
    setState(() {
      getlocation = [];
    });
    for (int i = 0; i < foundDonorsSorted.length; i++) {
      QueryBuilder<ParseObject> parseQuery =
          QueryBuilder<ParseObject>(ParseObject('donations'))
            ..whereEqualTo("donor_ID", foundDonorsSorted[i]);

      final ParseResponse apiResponse = await parseQuery.query();

      var DonationWithSpecificId = apiResponse.results as List<ParseObject>;

      print('DonationWithSpecificId  llll');
      print(DonationWithSpecificId);
      if (apiResponse.success && apiResponse.results != null) {
        for (int j = 0; j < DonationWithSpecificId.length; j++) {
          print(DonationWithSpecificId.length);
          var donation = DonationWithSpecificId[j];
          DateTime? dbOfferDate = DateTime.parse(donation.get("exp_date"));

          if (!dbOfferDate.isBefore(DateTime.now()) &&
              donation.get("req_donation_status") == 'Sent' &&
              donation.get("donor_ID") == foundDonorsSorted[i]) {
            print(getlocation.length);
            print('getlocation.length');
            print(locationF);

            getlocation.add(donation);
            print('found donation in get location');
            print(donation);
          }
        }
      }
      setState(() {
        getlocation1 = getlocation;
        items = [];
        items = getlocation;
      });
    }
    return getlocation;
  }

  void getDistance(double dLat, double dLon) async {
    double cLat = markers.elementAt(0).position.latitude;
    double cLon = markers.elementAt(0).position.longitude;

    distance = await Geolocator.distanceBetween(cLat, cLon, dLat, dLon);
    distancesList.add(distance);
    print(distance);
    print('list of distance');
    print(distancesList);
  }

  void getMarkers() async {
    setState(() {
      locationF = true;
    });
    getCHOs();
    QueryBuilder<ParseObject> parseQuery =
        QueryBuilder<ParseObject>(ParseObject('donations'));

    final ParseResponse apiResponse = await parseQuery.query();

    if (apiResponse.success && apiResponse.results != null) {
      setState(() {
        alldonations = apiResponse.results as List<ParseObject>;
        print('alldonations');
        print(alldonations);
        for (int i = 0; i < alldonations.length; i++) {
          var offer = alldonations[i];
          DateTime? dbOfferDate = DateTime.parse(offer.get("exp_date"));

          if (dbOfferDate.isBefore(DateTime.now())) {
            alldonations.remove(offer);
            items.remove(offer);
            print("old remove");
          }
        }
      });
      print('alldonations2');
      print(alldonations);
      //   ???????? ???? ???????? ???????? ??????????
      for (int i = 0; i < alldonations.length; i++) {
        var donorId = alldonations[i].get("donor_ID");

        print('donorId');
        print(donorId);
        QueryBuilder<ParseUser> queryUsers =
            QueryBuilder<ParseUser>(ParseUser.forQuery())
              ..whereEqualTo("objectId", alldonations[i].get("donor_ID"));
        final ParseResponse apiResponse = await queryUsers.query();

        if (apiResponse.success && apiResponse.results != null) {
          setState(() {
            donor = apiResponse.results as List<ParseObject>;
            print('donor');
            print(donor[0]);
          });

          if (!foundDonors.contains(donor[0].get("objectId"))) {
            foundDonors.add(donor[0].get("objectId"));
            setState(() {
              markers.add(Marker(
                  markerId: MarkerId(donor[0].get("name").toString()),
                  position: LatLng(donor[0].get("lat"),
                      donor[0].get("long")), //position of marker
                  infoWindow: InfoWindow(
                    //popup info
                    title: 'Marker ' + donor[0].get("name").toString(),
                  ),
                  icon: BitmapDescriptor.defaultMarker, //Icon for Marker

                  onTap: () {
                    getDistance(donor[0].get("lat"), donor[0].get("long"));

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$distance meters away from you')),
                    );
                  }));
              print(donor[0].get("lat"));
              getDistance(donor[0].get("lat"), donor[0].get("long"));

              print('marker added');
            });
          }
          print('foundDonors');
          print(foundDonors);
        }
      }
      print('Markers');
      print(markers.length);
      arrangment();
    } else {
      alldonations = [];
    }
  }

  void search1(String query) async {
    if (query.isNotEmpty) {
      match = [];

      for (int i = 0; i < allOffers.length; i++) {
        // var offer = Offers.fromMap(element);
        var offer = allOffers[i];

        var categories = offer.get("food_category").toString();
        var status = offer.get("food_status").toString();

        if (categories.toLowerCase().contains(query.toLowerCase()) ||
            status.toLowerCase().contains(query.toLowerCase())) {
          match.add(offer);
          print('yes match');
        }
      }

      setState(() {
        items = [];
        items.addAll(match);
      });
      return;
    } else {
      setState(() {
        items = [];
        items = allOffers;
      });
    }
  }

  void search(String query, var applay, var myAr, var locationF,
      var getlocation1) async {
    print('arrive search method');

    print('locationF ');
    print(locationF);
    print('getlocation1 ');

    print(getlocation1);

    var s = allOffers;
    if (locationF == true) {
      setState(() {
        items = [];
        items.addAll(getlocation1);
      });
    }
    if (query.isNotEmpty) {
      match = [];

      for (int i = 0; i < allOffers.length; i++) {
        // var offer = Offers.fromMap(element);
        var offer = allOffers[i];

        var categories = offer.get("food_category").toString();
        var status = offer.get("food_status").toString();

        if (categories.toLowerCase().contains(query.toLowerCase()) ||
            status.toLowerCase().contains(query.toLowerCase())) {
          match.add(offer);
          print('yes match');
        }
      }
      for (int i = 0; i < allOffers.length; i++) {
        var offer = allOffers[i];
        DateTime? dbOfferDate = DateTime.parse(offer.get("exp_date"));

        print('tody date');
        print(DateTime.now());
        print('offer date');
        print(dbOfferDate);
        print('all donations');
        print(allOffers.length);

        if (dbOfferDate.isBefore(DateTime.now())) {
          setState(() {
            items.remove(offer);
            allOffers.remove(offer);
            match.remove(offer);
            myAr.remove(offer);
            myArray2C.remove(offer);
            myArray2S.remove(offer);
            print("filter old remove");
          });
        }
      }

      setState(() {
        items = [];
        items.addAll(match);
      });
      return;
    } else if (locationF == true) {
      print('arrive search method');
      print('getlocation1 d');

      print(getlocation1);

      setState(() {
        items = [];
        items = getlocation1;
      });
    } else {
      setState(() {
        items = [];
        items = allOffers;
      });
    }

    if (myAr == null && apply == false && locationF == false) {
      print('Emptyyy');
      setState(() {
        items = [];

        items = allOffers;
      });
    }
    if (AllCategory == true && selectstatus == false) {
      print('Emptyyy');
      setState(() {
        items = [];
        items = allOffers;
      });
    }
    if (AllCategory == true && selectstatus == true) {
      setState(() {
        items = [];
        items = myArray2S;
      });
    }

    if (SelectCategory == true && selectstatus == true) {
      setState(() {
        items = [];
        items = myAr;
      });
    }

    if (SelectCategory == true && selectstatus == false) {
      setState(() {
        items = [];
        items = myArray2C;
      });
    }

    if (SelectCategory == false && selectstatus == true) {
      setState(() {
        items = [];
        items = myArray2S;
      });
    }

    /*else if (apply == true && myAr != null) {
      setState(() {
        items = myAr;
        print('items:');
        print(myAr);
      });
      return;
    }*/
  }

  var data;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomeC2(Cid)));
          },
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: Text(
          'Hayat food donation',
        ),
        backgroundColor: Colors.teal[200],
        elevation: 0.0,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 10, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: FlatButton(
                          height: 35,
                          minWidth: 50,
                          onPressed: () => {
                            getMarkers(),
                            print('getlocation after getMarkers'),
                            print(getlocation),
                          },
                          color: Colors.teal[200],
                          padding: EdgeInsets.all(0),
                          child: Column(
                            children: <Widget>[Icon(Icons.location_searching)],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Align(
                          alignment: Alignment.topRight,
                          child: FlatButton(
                            height: 35,
                            minWidth: 50,
                            onPressed: () => {
                              data = showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CustomDialog();
                                  }),
                            },
                            color: Colors.teal[200],
                            padding: EdgeInsets.all(0),
                            child: Column(
                              children: <Widget>[
                                Icon(Icons.filter_alt_outlined)
                              ],
                            ),
                          ))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          // search(value, apply, myArray);
                          search(value, apply, myArray, locationF, getlocation);
                        });
                      },
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search Offers..',
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        var offer = items[i];
                        print(offer);

                        return Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            // borderRadius: BorderRadius.circular(13),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 10,
                                  spreadRadius: 3,
                                  offset: Offset(3, 4))
                            ],
                          ),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => offerDetailes(
                                          SelectedOfferCategory: offer
                                              .get("food_category")
                                              .toString(),
                                          SelectedOfferStatus: offer
                                              .get("food_status")
                                              .toString(),
                                          SelectedAvailableQuantity:
                                              offer.get("aq").toString(),
                                          SelectedExpirationDate:
                                              offer.get("exp_date").toString(),
                                          SelectedPic:
                                              offer.get<ParseFile>("pic"),
                                          SelectedDonorId:
                                              offer.get("donor_ID").toString(),
                                          SelectedOfferId:
                                              offer.get("objectId").toString(),
                                          SelectedCHOId: Cid)));
                            },
                            /* leading:   Image.network(
                          offer.pic,
                          fit: BoxFit.cover,
                          width: 90,
                          height: 100,
                        ),*/
                            title: Text(
                                'Food Category:${offer.get("food_category").toString()}\n\nFood Status:${offer.get("food_status").toString()}\n\nEXP:${offer.get("exp_date").toString()}\n'),
                            subtitle: Text('Available Quantity' +
                                offer.get("aq").toString()),
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomDialog extends StatefulWidget {
  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  List<ParseObject> allOffers = <ParseObject>[];

  late bool Checked1Vegetables = false;
  late bool Checked2Fruits = false;
  late bool Checked3Meat = false;
  late bool Checked4Sea = false;
  late bool Checked5Bread = false;
  late bool Checked6Legumes = false;
  late bool Checked7Nuts = false;
  late bool Checked8Candy = false;
  late bool Checked8Dairy = false;
  late bool Checked9 = false;

  late bool Checked1Frozen = false;
  late bool Checked2Cooked = false;
  late bool Checked3Canned = false;
  late bool Checked4Chilled = false;
  late bool Checked5Fresh = false;
  late bool Checked6Dried = false;

  var SelectedCategory = [];
  var SelectedStatus = [];
  //late var allOffers = [];
  var items = [];
  var matchC = [];
  var matchS = [];
  var finalMatch = [];
  bool selectStatus2 = false;
  bool selectCategory2 = false;
  late var allOffers2 = [];
  void getOffers() async {
    QueryBuilder<ParseObject> parseQuery =
        QueryBuilder<ParseObject>(ParseObject('donations'))
          ..whereEqualTo("req_donation_status", 'Sent');

    final ParseResponse apiResponse = await parseQuery.query();

    if (apiResponse.success && apiResponse.results != null) {
      setState(() {
        allOffers = apiResponse.results as List<ParseObject>;
        items = allOffers as List<ParseObject>;
      });
      for (int i = 0; i < allOffers.length; i++) {
        var offer = allOffers[i];
        DateTime? dbOfferDate = DateTime.parse(offer.get("exp_date"));

        print('tody date');
        print(DateTime.now());
        print('offer date');
        print(dbOfferDate);
        print('all donations');
        print(allOffers.length);

        if (dbOfferDate.isBefore(DateTime.now())) {
          setState(() {
            items.remove(offer);
            allOffers.remove(offer);

            print("filter old remove");
          });
        }
      }
    } else {
      allOffers = [];
    }
    print(items);
  }

  @override
  void initState() {
    super.initState();

    getOffers();
  }

  void searchWithFilter(var SelectedCat, var SelectedSta) async {
    var SelectedCategories = SelectedCat;

    var query;

    for (int i = 0; i < SelectedCat.length; i++) {
      query = SelectedCat[i];
      print('query');

      print(query);
      var s = allOffers;
      if (query.isNotEmpty) {
        for (int i = 0; i < allOffers.length; i++) {
          // var offer = Offers.fromMap(element);
          var offer = allOffers[i];

          var categories = offer.get("food_category").toString();
          if (categories.toLowerCase().contains(query.toLowerCase())) {
            matchC.add(offer);
          }
        }

        print(matchC);
      }
    }
    var query2;
    var query4;
    var query5;
    var finalQueryC;
    var finalQueryS;
    var SelectedStatus = SelectedSta;
    print(SelectedSta);

    for (int i = 0; i < SelectedSta.length; i++) {
      query2 = SelectedSta[i];
      print('query');

      print(query2);
      var s = allOffers;
      if (query2.isNotEmpty) {
        for (int i = 0; i < allOffers.length; i++) {
          var offer = allOffers[i];

          var status = offer.get("food_status").toString();

          if (status.toLowerCase().contains(query2.toLowerCase())) {
            matchS.add(offer);
          }
        }

        print('matchSsssss');

        print(matchS);
      }
    }

    if (SelectedCategory.contains('Vegetables') ||
        SelectedCategory.contains('Fruits') ||
        SelectedCategory.contains('Meat') ||
        SelectedCategory.contains('Sea Food') ||
        SelectedCategory.contains('Bread') ||
        SelectedCategory.contains('Legumes') ||
        SelectedCategory.contains('Nuts and Seeds') ||
        SelectedCategory.contains('Candy') ||
        SelectedCategory.contains('Dairy')) {
      selectCategory2 = true;
    } else {
      selectCategory2 = false;
    }
    if (SelectedStatus.contains('Frozen') ||
        SelectedStatus.contains('Cooked') ||
        SelectedStatus.contains('Canned') ||
        SelectedStatus.contains('Chilled') ||
        SelectedStatus.contains('Fresh') ||
        SelectedStatus.contains('Dried')) {
      selectStatus2 = true;
    } else {
      selectStatus2 = false;
    }
    print('match C');
    print(matchC);
    print('match S');
    print(matchS);
    print('select category:  ');
    print(selectCategory2);
    print('select status:  ');
    print(selectStatus2);
    print('select category:  ');
    print(SelectedCat);
    print('select status:  ');
    print(SelectedSta);
    int a = SelectedCat.length;
    int b = SelectedSta.length;
    int grater;
    int smaller;

    print(a);
    print(b);

    int c = 0;
    if (a > b) {
      grater = SelectedCat.length;
      smaller = SelectedSta.length;
    } else {
      grater = SelectedSta.length;
      smaller = SelectedCat.length;
    }
    print('grater');
    print(grater);
    print('smaller');
    print(smaller);
//[vegetables,meat] [frozrn]
//[veg] []
    for (int i = 0; i < grater; i++) {
      if (grater == SelectedCat.length) {
        query4 = SelectedCat[i];
        finalQueryC = query4;
      } else {
        query4 = SelectedSta[i];
        finalQueryS = SelectedSta[i];
      }

      for (int j = 0; j < smaller; j++) {
        if (smaller == SelectedSta.length) {
          query5 = SelectedSta[j];
          finalQueryS = SelectedSta[j];
        } else {
          query5 = SelectedCat[j];
          finalQueryC = SelectedCat[j];
        }

        print('finalQueryC');
        print(finalQueryC);
        print('finalQueryS');
        print(finalQueryS);

        var s12 = allOffers;
        finalMatch = [];
        for (int i = 0; i < allOffers.length; i++) {
          var offer = allOffers[i];
          var categories = offer.get("food_category").toString();
          print('categories');
          print(categories);
          var status = offer.get("food_status").toString();
          print('status');
          print(status);
          if (categories.toLowerCase().contains(finalQueryC.toLowerCase()) &&
              status.toLowerCase().contains(finalQueryS.toLowerCase())) {
            print('yeass match');
            finalMatch.add(offer);
          }
        }

        print('final match :');
        print(finalMatch);
      }
    }

    for (int i = 0; i < finalMatch.length; i++) {
      var offer = allOffers[i];
      DateTime? dbOfferDate = DateTime.parse(offer.get("exp_date"));

      print('tody date');
      print(DateTime.now());
      print('offer date');
      print(dbOfferDate);
      print('all donations');
      print(allOffers.length);

      if (dbOfferDate.isBefore(DateTime.now())) {
        setState(() {
          items.remove(offer);
          allOffers.remove(offer);
          finalMatch.remove(offer);
          print("filter old remove");
        });
      }
    }
  }

  var apply = false;
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      child: Text(
                        'Category',
                        style: Theme.of(context).textTheme.headline5!.copyWith(
                              color: Colors.teal[200],
                            ),
                      ),
                    ),
                  ),
                  Column(
                    //height: 25,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CheckboxListTile(
                        title: Text("Vegetables"), //    <-- label
                        value: Checked1Vegetables,
                        onChanged: (newValue) {
                          setState(() {
                            Checked1Vegetables = newValue!;
                          });
                          if (Checked1Vegetables) {
                            SelectedCategory.add('Vegetables');
                            print(SelectedCategory);
                          } else if (!Checked1Vegetables) {
                            SelectedCategory.remove('Vegetables');
                            print(SelectedCategory);
                          }
                        },
                        activeColor: Colors.tealAccent[200],
                        checkColor: Colors.black87,
                      ),
                      CheckboxListTile(
                        title: Text("Fruits"), //    <-- label
                        value: Checked2Fruits,
                        onChanged: (newValue) {
                          setState(() {
                            Checked2Fruits = newValue!;
                          });
                          if (Checked2Fruits) {
                            SelectedCategory.add('Fruits');
                            print(SelectedCategory);
                          } else if (!Checked2Fruits) {
                            SelectedCategory.remove('Fruits');
                            print(SelectedCategory);
                          }
                        },
                        activeColor: Colors.tealAccent[200],
                        checkColor: Colors.black87,
                      ),
                      CheckboxListTile(
                        title: Text("Meat"), //    <-- label
                        value: Checked3Meat,
                        onChanged: (newValue) {
                          setState(() {
                            Checked3Meat = newValue!;
                          });
                          if (Checked3Meat) {
                            SelectedCategory.add('Meat');
                            print(SelectedCategory);
                          } else if (!Checked3Meat) {
                            SelectedCategory.remove('Meat');
                            print(SelectedCategory);
                          }
                        },
                        activeColor: Colors.tealAccent[200],
                        checkColor: Colors.black87,
                      ),
                      CheckboxListTile(
                        title: Text("Sea Food"), //    <-- label
                        value: Checked4Sea,
                        onChanged: (newValue) {
                          setState(() {
                            Checked4Sea = newValue!;
                          });
                          if (Checked4Sea) {
                            SelectedCategory.add('Sea Food');
                            print(SelectedCategory);
                          } else if (!Checked4Sea) {
                            SelectedCategory.remove('Sea Food');
                            print(SelectedCategory);
                          }
                        },
                        activeColor: Colors.tealAccent[200],
                        checkColor: Colors.black87,
                      ),
                      CheckboxListTile(
                        title: Text("Bread"), //    <-- label
                        value: Checked5Bread,
                        onChanged: (newValue) {
                          setState(() {
                            Checked5Bread = newValue!;
                          });
                          if (Checked5Bread) {
                            SelectedCategory.add('Bread');
                            print(SelectedCategory);
                          } else if (!Checked5Bread) {
                            SelectedCategory.remove('Bread');
                            print(SelectedCategory);
                          }
                        },
                        activeColor: Colors.tealAccent[200],
                        checkColor: Colors.black87,
                      ),
                      CheckboxListTile(
                        title: Text("Legumes"), //    <-- label
                        value: Checked6Legumes,
                        onChanged: (newValue) {
                          setState(() {
                            Checked6Legumes = newValue!;
                          });
                          if (Checked6Legumes) {
                            SelectedCategory.add('Legumes');
                            print(SelectedCategory);
                          } else if (!Checked6Legumes) {
                            SelectedCategory.remove('Legumes');
                            print(SelectedCategory);
                          }
                        },
                        activeColor: Colors.tealAccent[200],
                        checkColor: Colors.black87,
                      ),
                      CheckboxListTile(
                        title: Text("Nuts and Seeds"), //    <-- label
                        value: Checked7Nuts,
                        onChanged: (newValue) {
                          setState(() {
                            Checked7Nuts = newValue!;
                          });
                          if (Checked7Nuts) {
                            SelectedCategory.add('Nuts and Seeds');
                            print(SelectedCategory);
                          } else if (!Checked7Nuts) {
                            SelectedCategory.remove('Nuts and Seeds');
                            print(SelectedCategory);
                          }
                        },
                        activeColor: Colors.tealAccent[200],
                        checkColor: Colors.black87,
                      ),
                      CheckboxListTile(
                        title: Text("Candy"), //    <-- label
                        value: Checked8Candy,
                        onChanged: (newValue) {
                          setState(() {
                            Checked8Candy = newValue!;
                          });
                          if (Checked8Candy) {
                            SelectedCategory.add('Candy');
                            print(SelectedCategory);
                          } else if (!Checked8Candy) {
                            SelectedCategory.remove('Candy');
                            print(SelectedCategory);
                          }
                        },
                        activeColor: Colors.tealAccent[200],
                        checkColor: Colors.black87,
                      ),
                      CheckboxListTile(
                        title: Text("Dairy"), //    <-- label
                        value: Checked8Dairy,
                        onChanged: (newValue) {
                          setState(() {
                            Checked8Dairy = newValue!;
                          });
                          if (Checked8Dairy) {
                            SelectedCategory.add('Dairy');
                            print(SelectedCategory);
                          } else if (!Checked8Dairy) {
                            SelectedCategory.remove('Dairy');
                            print(SelectedCategory);
                          }
                        },
                        activeColor: Colors.tealAccent[200],
                        checkColor: Colors.black87,
                      ),
                      CheckboxListTile(
                        title: Text("All"), //    <-- label
                        value: Checked9,
                        onChanged: (newValue) {
                          setState(() {
                            Checked9 = newValue!;
                          });
                        },
                        activeColor: Colors.tealAccent[200],
                        checkColor: Colors.black87,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      child: Text(
                        'Status',
                        style: Theme.of(context).textTheme.headline5!.copyWith(
                              color: Colors.teal[200],
                            ),
                      ),
                    ),
                  ),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CheckboxListTile(
                          title: Text("Frozen"), //    <-- label
                          value: Checked1Frozen,
                          onChanged: (newValue) {
                            setState(() {
                              Checked1Frozen = newValue!;
                            });
                            if (Checked1Frozen) {
                              SelectedStatus.add('Frozen');
                              print(SelectedStatus);
                            } else if (!Checked1Frozen) {
                              SelectedStatus.remove('Frozen');
                              print(SelectedStatus);
                            }
                          },
                          activeColor: Colors.tealAccent[200],
                          checkColor: Colors.black87,
                        ),
                        CheckboxListTile(
                          title: Text("Cooked"), //    <-- label
                          value: Checked2Cooked,
                          onChanged: (newValue) {
                            setState(() {
                              Checked2Cooked = newValue!;
                            });
                            if (Checked2Cooked) {
                              SelectedStatus.add('Cooked');
                              print(SelectedStatus);
                            } else if (!Checked2Cooked) {
                              SelectedStatus.remove('Cooked');
                              print(SelectedStatus);
                            }
                          },
                          activeColor: Colors.tealAccent[200],
                          checkColor: Colors.black87,
                        ),
                        CheckboxListTile(
                          title: Text("Canned"), //    <-- label
                          value: Checked3Canned,
                          onChanged: (newValue) {
                            setState(() {
                              Checked3Canned = newValue!;
                            });
                            if (Checked3Canned) {
                              SelectedStatus.add('Canned');
                              print(SelectedStatus);
                            } else if (!Checked3Canned) {
                              SelectedStatus.remove('Canned');
                              print(SelectedStatus);
                            }
                          },
                          activeColor: Colors.tealAccent[200],
                          checkColor: Colors.black87,
                        ),
                        CheckboxListTile(
                          title: Text("Chilled"), //    <-- label
                          value: Checked4Chilled,
                          onChanged: (newValue) {
                            setState(() {
                              Checked4Chilled = newValue!;
                            });
                            if (Checked4Chilled) {
                              SelectedStatus.add('Chilled');
                              print(SelectedStatus);
                            } else if (!Checked4Chilled) {
                              SelectedStatus.remove('Chilled');
                              print(SelectedStatus);
                            }
                          },
                          activeColor: Colors.tealAccent[200],
                          checkColor: Colors.black87,
                        ),
                        CheckboxListTile(
                          title: Text("Fresh"), //    <-- label
                          value: Checked5Fresh,
                          onChanged: (newValue) {
                            setState(() {
                              Checked5Fresh = newValue!;
                            });
                            if (Checked5Fresh) {
                              SelectedStatus.add('Fresh');
                              print(SelectedStatus);
                            } else if (!Checked5Fresh) {
                              SelectedStatus.remove('Fresh');
                              print(SelectedStatus);
                            }
                          },
                          activeColor: Colors.tealAccent[200],
                          checkColor: Colors.black87,
                        ),
                        CheckboxListTile(
                          title: Text("Dried"), //    <-- label
                          value: Checked6Dried,
                          onChanged: (newValue) {
                            setState(() {
                              Checked6Dried = newValue!;
                            });
                            if (Checked6Dried) {
                              SelectedStatus.add('Dried');
                              print(SelectedStatus);
                            } else if (!Checked6Dried) {
                              SelectedStatus.remove('Dried');
                              print(SelectedStatus);
                            }
                          },
                          activeColor: Colors.tealAccent[200],
                          checkColor: Colors.black87,
                        ),
                      ])
                ],
              ),
            ),
          ),
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.teal.shade100),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)))),
              onPressed: () async {
                setState(() {
                  searchWithFilter(SelectedCategory, SelectedStatus);
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ListOffersPage3(
                            myArray: finalMatch,
                            myArray2S: matchS,
                            myArray2C: matchC,
                            apply: true,
                            AllCategory: Checked9,
                            SelectCategory: selectCategory2,
                            selectstatus: selectStatus2,
                          )),
                );
                //String text = "Data that we want to pass. Can be anything.";
                // Navigator.pop(context, match);
              },
              child: const Text(
                'Apply',
                style: TextStyle(fontSize: 20, color: Colors.black),
              )),
        ],
      ),
    );
  }
}
