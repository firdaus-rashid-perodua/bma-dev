import 'dart:convert';
// import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test_1/model/actXtarget_model.dart';
import 'package:intl/intl.dart';

class Api {
  // static const ldapUrl = "http://192.168.238.124/"; //ldap
  // static const baseUrl = "http://192.168.238.124:80/api/";
  // static const ldapUrl = "https://devprimego.perodua.com.my/"; //ldap
  // static const baseUrl = "https://devprimego.perodua.com.my/api/";
  // static const ldapUrl = "http://10.1.115.9/"; //ldap
  // static const baseUrl = "http://10.1.115.9/api/";
  // static const baseUrl = "  http://localhost/api/";

  static const String baseUrl = String.fromEnvironment('API_BASE_URL');
  static const String ldapUrl = String.fromEnvironment('API_LDAP_URL');

  // DateTime now = DateTime.now();
  // String currMonth = DateFormat('MM').format(DateTime.now());
  // String currYear = DateFormat.y().format(DateTime.now());
  String currMonth = '07';
  String currYear = '2025';

  get_currDate() async {
    return {
      "success": true,
      "count": 1,
      "data": [
        {"curr_month": "$currMonth", "curr_year": "$currYear"},
      ],
    };
  }

  //login
  // Add this inside your API class
  static loginUser(String username, String password) async {
    try {
      /* String rawUsername = username.trim();

      if (!rawUsername.toLowerCase().endsWith('@perodua.com.my')) {
        rawUsername = '$rawUsername@perodua.com.my';
      } */

      print("Api.dart - loginUser() targeting: $username");

      final res = await http
          .post(
            Uri.parse(ldapUrl + "login-direct"),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(
            const Duration(seconds: 5),
          ); // Higher timeout allowance for login queries

      var data = jsonDecode(res.body);
      print("Api.dart - loginUser() status ${res.statusCode} : $data");

      if (res.statusCode == 200) {
        // Return your success data payload
        return {"success": true, "data": data};
      } else {
        // Return server error message (e.g., wrong password/user not found)
        return {"success": false, "message": data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      debugPrint('Api.dart - loginUser() exception: ' + e.toString());
      return {
        "success": false,
        "message":
            "Connection to authentication server failed. " +
            ldapUrl +
            " " +
            e.toString(),
        "error": e.toString(),
      };
    }
  }
  //end login

  get_actYearReg() async {
    List<actTarget> reg_yearAct = [];

    String uriParam = "?year=$currYear";

    try {
      final res = await http
          .get(Uri.parse(baseUrl + "dashboard/year_regActual" + uriParam))
          .timeout(const Duration(seconds: 5)); // placed right after http.get()

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        //print("ok");
        print("Api.dart - get_actYearReg() : $data");
        print("month: $currMonth");
        print("year: $currYear");

        return data;
      } else {
        var data = jsonDecode(res.body);
        return data;
      }
    } catch (e) {
      debugPrint('Api.dart - get_actYearReg() : ' + e.toString());
      // return [];
      return {
        "success": false,
        "message": "Failed to read database table",
        "error": e.toString(),
      };
    }
  }

  static get_tgtYearReg() async {
    List<regTarget> reg_yearTgt = [];

    try {
      final res = await http
          .get(Uri.parse(baseUrl + "dashboard/year_regTarget"))
          .timeout(const Duration(seconds: 5));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        //print("ok");
        print("Api.dart - get_tgtYearReg() : $data");

        return data;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Api.dart - get_tgtYearReg() : ' + e.toString());
      // return [];
      return {
        "success": false,
        "message": "Failed to read database table",
        "error": e.toString(),
      };
    }
  }

  get_actMntReg() async {
    List<actTarget> reg_mntAct = [];

    // String uriParam = "?month=$currMonth&year=$currYear";
    String uriParam = "?month=$currMonth&year=$currYear";

    try {
      final res = await http
          .get(Uri.parse(baseUrl + "dashboard/mnt_regActual" + uriParam))
          .timeout(const Duration(seconds: 5));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        //print("ok");
        print("Api.dart - get_actMntReg() result : $data");

        return data;
      } else {
        var data = jsonDecode(res.body);
        print("Api.dart - get_actMntReg() : $data");
        return data;
      }
    } catch (e) {
      debugPrint('Api.dart - get_actMntReg() : ' + e.toString());
      //return [];
      return {
        "success": false,
        "message": "Failed to read database table",
        "error": e.toString(),
        "data": [],
      };
    }
  }

  get_tgtMntReg() async {
    List<regTarget> reg_mntTgt = [];

    String uriParam = "?month=$currMonth&year=$currYear";

    try {
      final res = await http
          .get(Uri.parse(baseUrl + "dashboard/mnt_regTarget" + uriParam))
          .timeout(const Duration(seconds: 5));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        //print("ok");
        print("Api.dart - get_tgtMntReg() : $data");

        return data;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Api.dart - get_tgtMntReg() : ' + e.toString());
      // return [];
      return {
        "success": false,
        "message": "Failed to read database table",
        "error": e.toString(),
      };
    }
  }

  static get_actMntBook() async {
    List<actTarget> book_mntAct = [];

    try {
      final res = await http
          .get(Uri.parse(baseUrl + "dashboard/mnt_bookActual"))
          .timeout(const Duration(seconds: 5));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print("Api.dart - get_actMntBook() : $data");

        return data;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Api.dart - get_actMntBook() : ' + e.toString());
      // return [];
      return {
        "success": false,
        "message": "Failed to read database table",
        "error": e.toString(),
      };
    }
  }

  static get_tgtMntBook() async {
    List<regTarget> book_mntTgt = [];

    try {
      final res = await http
          .get(Uri.parse(baseUrl + "dashboard/mnt_bookTarget"))
          .timeout(const Duration(seconds: 5));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        //print("ok");
        print("Api.dart - get_tgtMntBook() : $data");

        return data;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Api.dart - get_tgtMntBook() : ' + e.toString());
      // return [];
      return {
        "success": false,
        "message": "Failed to read database table",
        "error": e.toString(),
      };
    }
  }

  get_RegionListMntReg() async {
    List<actTarget> reg_RegionListmntAct = [];

    // String uriParam = "?month=$currMonth&year=$currYear";
    String uriParam = "?month=$currMonth&year=$currYear";

    try {
      final res = await http
          .get(Uri.parse(baseUrl + "registration/mnt_listActual" + uriParam))
          .timeout(const Duration(seconds: 5));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        //print("ok");
        // print("Api.dart - get_RegionListMntReg() result : $data");
        print("Api.dart - get_RegionListMntReg()");

        return data;
      } else {
        var data = jsonDecode(res.body);
        print("Api.dart - get_RegionListMntReg() : $data");
        return data;
      }
    } catch (e) {
      debugPrint('Api.dart - get_RegionListMntReg() : ' + e.toString());
      //return [];
      return {
        "success": false,
        "message": "Failed to read database table",
        "error": e.toString(),
        "data": [],
      };
    }
  }

  get_RegionListMntRegModel() async {
    List<actTarget> reg_RegionListmntActModel = [];

    // String uriParam = "?month=$currMonth&year=$currYear";
    String uriParam = "?month=$currMonth&year=$currYear";

    try {
      final res = await http
          .get(
            Uri.parse(baseUrl + "registration/mnt_listActualModel" + uriParam),
          )
          .timeout(const Duration(seconds: 4));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        //print("ok");
        // print("Api.dart - get_RegionListMntRegModel() result : $data");
        print("Api.dart - get_RegionListMntRegModel()");

        return data;
      } else {
        var data = jsonDecode(res.body);
        print("Api.dart - get_RegionListMntRegModel() : $data");
        return data;
      }
    } catch (e) {
      debugPrint('Api.dart - get_RegionListMntRegModel() : ' + e.toString());
      //return [];
      return {
        "success": false,
        "message": "Failed to read database table",
        "error": e.toString(),
        "data": [],
      };
    }
  }

  get_RegionListMntRegOutlets(String regionCode) async {
    List<actTarget> reg_RegionListMntOutlets = [];

    // String uriParam = "?month=$currMonth&year=$currYear";
    String uriParam = "?month=$currMonth&year=$currYear&region=$regionCode";

    try {
      final res = await http
          .get(
            Uri.parse(baseUrl + "registration/mnt_listRegionOutlet" + uriParam),
          )
          .timeout(const Duration(seconds: 4));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        //print("ok");
        // print("Api.dart - get_RegionListMntRegOutlets() result : $data");
        print("Api.dart - get_RegionListMntRegOutlets()");

        return data;
      } else {
        var data = jsonDecode(res.body);
        print("Api.dart - get_RegionListMntRegOutlets() : $data");
        return data;
      }
    } catch (e) {
      debugPrint('Api.dart - get_RegionListMntRegOutlets() : ' + e.toString());
      //return [];
      return {
        "success": false,
        "message": "Failed to read database table",
        "error": e.toString(),
        "data": [],
      };
    }
  }

  get_ModelListOfOutlet(String outletcode) async {
    //List<actTarget> reg_RegionListMntOutlets = [];

    // String uriParam = "?month=$currMonth&year=$currYear";
    String uriParam = "?month=$currMonth&year=$currYear&outletcode=$outletcode";

    try {
      final res = await http
          .get(
            Uri.parse(baseUrl + "registration/mnt_listModelOutlet" + uriParam),
          )
          .timeout(const Duration(seconds: 4));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        //print("ok");
        // print("Api.dart - get_ModelListOfOutlet() result : $data");
        print("Api.dart - get_ModelListOfOutlet()");

        return data;
      } else {
        var data = jsonDecode(res.body);
        print("Api.dart - get_ModelListOfOutlet() : $data");
        return data;
      }
    } catch (e) {
      debugPrint('Api.dart - get_ModelListOfOutlet() : ' + e.toString());
      //return [];
      return {
        "success": false,
        "message": "Failed to read database table",
        "error": e.toString(),
        "data": [],
      };
    }
  }

  get_RegionMntRegOutletSummary(String regionCode) async {
    List<actTarget> reg_RegionListMntOutlets = [];

    // String uriParam = "?month=$currMonth&year=$currYear";
    String uriParam = "?month=$currMonth&year=$currYear&region=$regionCode";

    try {
      final res = await http
          .get(
            Uri.parse(
              baseUrl + "registration/mnt_RegionOutletSummary" + uriParam,
            ),
          )
          .timeout(const Duration(seconds: 4));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        //print("ok");
        // print("Api.dart - get_RegionListMntRegOutlets() result : $data");
        print("Api.dart - get_RegionMntRegOutletSummary()");

        return data;
      } else {
        var data = jsonDecode(res.body);
        print("Api.dart - get_RegionMntRegOutletSummary() : $data");
        return data;
      }
    } catch (e) {
      debugPrint(
        'Api.dart - get_RegionMntRegOutletSummary() : ' + e.toString(),
      );
      //return [];
      return {
        "success": false,
        "message": "Failed to read database table",
        "error": e.toString(),
        "data": [],
      };
    }
  }

  get_MntOutletModelSummary(String outletcode) async {
    List<actTarget> reg_MntOutletModelSummary = [];

    // String uriParam = "?month=$currMonth&year=$currYear";
    String uriParam = "?month=$currMonth&year=$currYear&outletcode=$outletcode";

    try {
      final res = await http
          .get(
            Uri.parse(
              baseUrl + "registration/mnt_outletModelResult" + uriParam,
            ),
          )
          .timeout(const Duration(seconds: 4));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        //print("ok");
        // print("Api.dart - get_RegionListMntRegOutlets() result : $data");
        print("Api.dart - get_RegionMntRegOutletSummary()");

        return data;
      } else {
        var data = jsonDecode(res.body);
        print("Api.dart - get_RegionMntRegOutletSummary() : $data");
        return data;
      }
    } catch (e) {
      debugPrint(
        'Api.dart - get_RegionMntRegOutletSummary() : ' + e.toString(),
      );
      //return [];
      return {
        "success": false,
        "message": "Failed to read database table",
        "error": e.toString(),
        "data": [],
      };
    }
  }

  //BOOKING

  get_actMntBkg() async {
    List<actTarget> reg_mntAct = [];

    // String uriParam = "?month=$currMonth&year=$currYear";
    String uriParam = "?month=$currMonth&year=$currYear";

    try {
      final res = await http
          .get(Uri.parse(baseUrl + "dashboard/mnt_bkgActual" + uriParam))
          .timeout(const Duration(seconds: 5));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        //print("ok");
        print("Api.dart - get_actMntBkg() result : $data");

        return data;
      } else {
        var data = jsonDecode(res.body);
        print("Api.dart - get_actMntBkg() : $data");
        return data;
      }
    } catch (e) {
      debugPrint('Api.dart - get_actMntBkg() : ' + e.toString());
      //return [];
      return {
        "success": false,
        "message": "Failed to read database table",
        "error": e.toString(),
        "data": [],
      };
    }
  }

  get_tgtMntBkg() async {
    // List<actTarget> reg_mntAct = [];

    // String uriParam = "?month=$currMonth&year=$currYear";
    String uriParam = "?month=$currMonth&year=$currYear";

    try {
      final res = await http
          .get(Uri.parse(baseUrl + "dashboard/mnt_bkgTarget" + uriParam))
          .timeout(const Duration(seconds: 5));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        //print("ok");
        print("Api.dart - get_tgtMntBkg() result : $data");

        return data;
      } else {
        var data = jsonDecode(res.body);
        print("Api.dart - get_tgtMntBkg() : $data");
        return data;
      }
    } catch (e) {
      debugPrint('Api.dart - get_tgtMntBkg() : ' + e.toString());
      //return [];
      return {
        "success": false,
        "message": "Failed to read database table",
        "error": e.toString(),
        "data": [],
      };
    }
  }

  get_RegionListMntBkg() async {
    List<actTarget> reg_RegionListmntAct = [];

    // String uriParam = "?month=$currMonth&year=$currYear";
    String uriParam = "?month=$currMonth&year=$currYear";

    try {
      final res = await http
          .get(Uri.parse(baseUrl + "booking/mnt_ListActual_ora" + uriParam))
          .timeout(const Duration(seconds: 25));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        //print("ok");
        // print("Api.dart - get_RegionListMntBkg() result : $data");
        print("Api.dart - get_RegionListMntBkg()");

        return data;
      } else {
        var data = jsonDecode(res.body);
        print("Api.dart - get_RegionListMntBkg() : $data");
        return data;
      }
    } catch (e) {
      debugPrint('Api.dart - get_RegionListMntBkg() : ' + e.toString());
      //return [];
      return {
        "success": false,
        "message": "Failed to read database table",
        "error": e.toString(),
        "data": [],
      };
    }
  }

  get_RegionListMntBkgOutlets(String regionCode) async {
    // List<actTarget> reg_RegionListMntOutlets = [];

    // String uriParam = "?month=$currMonth&year=$currYear";
    String uriParam = "?month=$currMonth&year=$currYear&region=$regionCode";

    try {
      final res = await http
          .get(
            Uri.parse(baseUrl + "booking/mnt_listRegionOutlet_ora" + uriParam),
          )
          .timeout(const Duration(seconds: 4));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        //print("ok");
        // print("Api.dart - get_RegionListMntBkgOutlets() result : $data");
        print("Api.dart - get_RegionListMntBkgOutlets()");

        return data;
      } else {
        var data = jsonDecode(res.body);
        print("Api.dart - get_RegionListMntBkgOutlets() : $data");
        return data;
      }
    } catch (e) {
      debugPrint('Api.dart - get_RegionListMntBkgOutlets() : ' + e.toString());
      //return [];
      return {
        "success": false,
        "message": "Failed to read database table",
        "error": e.toString(),
        "data": [],
      };
    }
  }

  //
  //
}
