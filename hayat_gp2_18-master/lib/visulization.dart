import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Chart extends StatefulWidget {
  Chart(this.Cid, {Key? key}) : super(key: key);
  var Cid;

  @override
  _ChartState createState() => _ChartState(this.Cid);
}

class _ChartState extends State<Chart> {
  var Cid;
  _ChartState(this.Cid);
  List<GDPData> chartData = [
    GDPData('Donations : ', 0),
    GDPData('Contracts : ', 0),
    GDPData('People covered : ', 0),
  ];
  int donations = 0;
  int contracts = 0;
  int quantity = 0;
  List<ParseObject> allDonations = <ParseObject>[];
  List<ParseObject> allContracts = <ParseObject>[];

  void getDonations(String? CID) async {
    QueryBuilder<ParseObject> parseQuery =
        QueryBuilder<ParseObject>(ParseObject('donations'))
          ..whereEqualTo("RequesterCHOid", CID)
          ..whereEqualTo("req_donation_status", "Delivered");

    final ParseResponse apiResponse = await parseQuery.query();

    if (apiResponse.success && apiResponse.results != null) {
      setState(() {
        allDonations = apiResponse.results as List<ParseObject>;
        donations = allDonations.length;
      });
    } else {
      donations = 0;
    }
    print(donations);
    for (int i = 0; i < allDonations.length; i++) {
      int q = allDonations[i].get('aq');
      setState(() {
        quantity = quantity + q;
      });
    }
    getContracts(Cid);
  }

  void getContracts(String? CID) async {
    QueryBuilder<ParseObject> parseQuery =
        QueryBuilder<ParseObject>(ParseObject('contracts'))
          ..whereEqualTo("cho_id", CID)
          ..whereEqualTo("contract_status", "Complete");

    final ParseResponse apiResponse = await parseQuery.query();

    if (apiResponse.success && apiResponse.results != null) {
      setState(() {
        allContracts = apiResponse.results as List<ParseObject>;
        contracts = allContracts.length;
      });
    } else {
      contracts = 0;
    }
    print("c : $contracts");
    setState(() {
      chartData = [
        GDPData('Donations : $donations', donations),
        GDPData('Contracts : $contracts', contracts),
        GDPData('People covered : $quantity', quantity),
      ];
    });
  }

  @override
  void initState() {
    getDonations(Cid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Hayat food donation',
          ),
          backgroundColor: Colors.teal[200],
          elevation: 0.0,
        ),
        body: SfCircularChart(
          title: ChartTitle(
              text: 'Statistics about your charity',
              textStyle: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          legend: Legend(
              isVisible: true,
              overflowMode: LegendItemOverflowMode.wrap,
              textStyle: TextStyle(fontSize: 18)),
          series: <CircularSeries>[
            PieSeries<GDPData, String>(
              dataSource: chartData,
              xValueMapper: (GDPData data, _) => data.continent,
              yValueMapper: (GDPData data, _) => data.gdp,
              dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  textStyle:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            )
          ],
        ));
  }
}

class GDPData {
  GDPData(this.continent, this.gdp);
  final String continent;
  final int gdp;
}
