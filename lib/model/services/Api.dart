import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:flutter_native_certs/flutter_native_certs.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:test_1/global.dart';
import 'package:test_1/model/actXtarget_model.dart';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';

class Api {
  // static const ldapUrl = "https://devprimego.perodua.com.my/"; //ldap
  // static const baseUrl = "https://devprimego.perodua.com.my/api/";

  static const String baseUrl = String.fromEnvironment('API_BASE_URL');
  static const String ldapUrl = String.fromEnvironment('API_LDAP_URL');

  static final _storage = FlutterSecureStorage();

  // Shared HTTP client that trusts certs from the device's native store
  // commented due to SPA - 28/09/2026
  /* static http.Client get _client => IOClient(
    HttpClient(context: FlutterNativeCerts.instance.securityContext),
  ); */

  // Your server's valid SHA-256 certificate fingerprint
  // run in server >>openssl s_client -connect devprimego.perodua.com.my:443 </dev/null 2>/dev/null | openssl x509 -noout -fingerprint -sha256
  // remove the colon : , make it all lowercase
  static const List<String> _pinnedFingerprints = [
    "c691463d9a532a6078a18b023d4b4482554bd028c4acd92438c07a3921cb23ef", // dev
    "3037e3ff30b3ad1f06d1fbf1f6daa87a51dbc63b8fe62d4d30f5c5bb6265d44f", // uat
    "c6298f35ef7be0a79f3a8444a3e71f2e227fc691e81cc118e188e2d1fe3e9916", // prod
  ];

  static http.Client get _client {
    final httpClient = HttpClient(
      context: FlutterNativeCerts.instance.securityContext,
    );

    // Intercept connection logic to validate the certificate chain
    httpClient
        .badCertificateCallback = (X509Certificate cert, String host, int port) {
      // 4. Compute the SHA-256 hash of the server's DER-encoded certificate bytes
      final hash = sha256.convert(cert.der).toString().toLowerCase();

      // 5. Allow connection only if the fingerprint matches our pins
      if (_pinnedFingerprints.contains(hash)) {
        return true; // Explicitly trust the certificate
      }

      debugPrint(
        "SECURITY WARNING: Certificate pinning validation failed for $host!",
      );
      return false; // Aborts connection immediately (MitM protection)
    };

    return IOClient(httpClient);
  }

  // DateTime now = DateTime.now();
  static String currMonth = DateFormat('MM').format(DateTime.now());
  static String currYear = DateFormat.y().format(DateTime.now());
  // static String currMonth = '06';
  // static String currYear = '2026';

  // --- token storage helpers ---
  static Future<void> _storeToken(String token) async {
    print("_storeToken: " + token);
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // public wrapper — other files can call this
  static Future<String?> getStoredToken() async {
    return await _getToken();
  }

  static Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  // --- shared headers, used by every authenticated call ---
  static Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

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

      final res = await _client
          .post(
            Uri.parse(ldapUrl + "login-direct"),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(
            const Duration(seconds: 10),
          ); // Higher timeout allowance for login queries

      var data = jsonDecode(res.body);
      print("Api.dart - loginUser() status ${res.statusCode} : $data");

      if (res.statusCode == 200) {
        // Return your success data payload
        if (data['token'] != null) {
          await _storeToken(data['token']);
        }
        return {"success": true, "data": data};
      } else {
        // Return server error message (e.g., wrong password/user not found)
        return {"success": false, "message": data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      debugPrint('Api.dart - loginUser() exception: ' + e.toString());
      return {
        "success": false,
        "message": "Connection to authentication server failed.",
        "error": "",
        // "message":
        //     "Connection to authentication server failed. " +
        //     ldapUrl +
        //     " " +
        //     e.toString(),
        // "error": e.toString(), //commented for spa
      };
    }
  }
  //end login

  get_userACL() async {
    // List<actTarget> reg_yearAct = [];

    String uriParam = "?username=$globalUserEmail";

    try {
      final token = await getStoredToken();
      final res = await _client
          .get(
            Uri.parse(baseUrl + "user-access" + uriParam),
            headers: await _authHeaders(),
          )
          .timeout(
            const Duration(seconds: 10),
          ); // placed right after http.get()

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print("Api.dart - get_userACL() result : $data");

        return data;
      } else {
        var data = jsonDecode(res.body);
        return data;
      }
    } catch (e) {
      debugPrint('Api.dart - get_userACL() result : ' + e.toString());
      // return [];
      return {
        "success": false,
        "message": "Failed to read database table",
        "error": e.toString(),
      };
    }
  }

  get_ackReg() async {
    List<actTarget> reg_yearAct = [];

    // String uriParam = "?year=$currYear";

    try {
      final token = await getStoredToken();
      final res = await _client
          // .get(Uri.parse(baseUrl + "dashboard/ack_registration_temp"))
          .get(
            Uri.parse(baseUrl + "dashboard/ack_registration_temp"),
            headers: await _authHeaders(),
          )
          .timeout(
            const Duration(seconds: 10),
          ); // placed right after http.get()

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print("Api.dart - get_ackReg() result : $data");

        return data;
      } else {
        var data = jsonDecode(res.body);
        return data;
      }
    } catch (e) {
      debugPrint('Api.dart - get_ackReg() result : ' + e.toString());
      // return [];
      return {
        "success": false,
        "message": "Failed to read database table",
        "error": e.toString(),
      };
    }
  }

  get_actYearReg() async {
    List<actTarget> reg_yearAct = [];

    String uriParam = "?year=$currYear";

    try {
      final token = await getStoredToken();
      final res = await _client
          .get(
            Uri.parse(baseUrl + "dashboard/year_regActual" + uriParam),
            headers: await _authHeaders(),
          )
          .timeout(
            const Duration(seconds: 10),
          ); // placed right after http.get()

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        // print("Api.dart - get_actYearReg() : $data");
        // print("month: $currMonth");
        // print("year: $currYear");

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

    String uriParam = "?year=$currYear";

    try {
      final token = await getStoredToken();
      final res = await _client
          .get(
            Uri.parse(baseUrl + "dashboard/year_regTarget" + uriParam),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print("Api.dart - get_tgtYearReg() : $data");

        return data;
      } else {
        print("Api.dart - fail get_tgtYearReg()");
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
      final token = await getStoredToken();
      final res = await _client
          .get(
            Uri.parse(baseUrl + "dashboard/mnt_regActual" + uriParam),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
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
      final token = await getStoredToken();
      final res = await _client
          .get(
            Uri.parse(baseUrl + "dashboard/mnt_regTarget" + uriParam),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print("Api.dart - get_tgtMntReg() result : $data");

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
      final token = await getStoredToken();
      final res = await _client
          .get(
            Uri.parse(baseUrl + "dashboard/mnt_bookActual"),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 10));
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
      final token = await getStoredToken();
      final res = await _client
          .get(
            Uri.parse(baseUrl + "dashboard/mnt_bookTarget"),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
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
      final token = await getStoredToken();
      final res = await _client
          .get(
            Uri.parse(baseUrl + "registration/mnt_listActual" + uriParam),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
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
      final token = await getStoredToken();
      final res = await _client
          .get(
            Uri.parse(baseUrl + "registration/mnt_listActualModel" + uriParam),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
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

  get_mntModelListActual() async {
    List<actTarget> reg_RegionListmntActModel = [];

    // String uriParam = "?month=$currMonth&year=$currYear";
    String uriParam = "?month=$currMonth&year=$currYear";

    try {
      final token = await getStoredToken();
      final res = await _client
          .get(
            Uri.parse(
              baseUrl + "registration/month/model/list_actual" + uriParam,
            ),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
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

  get_mntBkgModelListActual() async {
    List<actTarget> reg_RegionListmntActModel = [];

    // String uriParam = "?month=$currMonth&year=$currYear";
    String uriParam = "?month=$currMonth&year=$currYear";
    // String fmrid = '&fmrid=C10106,C10114,C10102,C10107';
    // String fmrid = '&fmrid=' + fmrid_param_all;

    // uriParam = uriParam + fmrid;

    try {
      final token = await getStoredToken();
      final res = await _client
          .get(
            Uri.parse(baseUrl + "booking/month/model/list_actual" + uriParam),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print("Api.dart - get_mntBkgModelListActual()");

        return data;
      } else {
        var data = jsonDecode(res.body);
        print("Api.dart - get_mntBkgModelListActual() : $data");
        return data;
      }
    } catch (e) {
      debugPrint('Api.dart - get_mntBkgModelListActual() : ' + e.toString());
      //return [];
      return {
        "success": false,
        "message": "Failed to read database table",
        "error": e.toString(),
        "data": [],
      };
    }
  }

  get_mntBkgModelListTarget() async {
    List<actTarget> reg_RegionListmntActModel = [];

    // String uriParam = "?month=$currMonth&year=$currYear";
    String uriParam = "?month=$currMonth&year=$currYear";
    // String fmrid = '&fmrid=C10106,C10114,C10102,C10107';
    // String fmrid = '&fmrid=' + fmrid_param_all;

    // uriParam = uriParam + fmrid;

    try {
      final token = await getStoredToken();
      final res = await _client
          .get(
            Uri.parse(baseUrl + "booking/month/model/list_target" + uriParam),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print("Api.dart - get_mntBkgModelListActual()");

        return data;
      } else {
        var data = jsonDecode(res.body);
        print("Api.dart - get_mntBkgModelListActual() : $data");
        return data;
      }
    } catch (e) {
      debugPrint('Api.dart - get_mntBkgModelListActual() : ' + e.toString());
      //return [];
      return {
        "success": false,
        "message": "Failed to read database table",
        "error": e.toString(),
        "data": [],
      };
    }
  }

  get_modelMaintenance_fmrid() async {
    List<actTarget> reg_RegionListmntActModel = [];

    String uriParam = '';
    // String uriParam = '?fmrid=' + fmrid_param_all;

    try {
      final token = await getStoredToken();
      final res = await _client
          .get(
            Uri.parse(baseUrl + "maintenance/model/all" + uriParam),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print("Api.dart - get_modelMaintenance_fmrid()");

        return data;
      } else {
        var data = jsonDecode(res.body);
        print("Api.dart - get_modelMaintenance_fmrid() : $data");
        return data;
      }
    } catch (e) {
      debugPrint('Api.dart - get_modelMaintenance_fmrid() : ' + e.toString());
      //return [];
      return {
        "success": false,
        "message": "Failed to read database table",
        "error": e.toString(),
        "data": [],
      };
    }
  }

  get_mntModelListTarget() async {
    // String uriParam = "?month=$currMonth&year=$currYear";
    String uriParam = "?month=$currMonth&year=$currYear";

    try {
      final token = await getStoredToken();
      final res = await _client
          .get(
            Uri.parse(
              baseUrl + "registration/month/model/list_target" + uriParam,
            ),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print("Api.dart - get_mntModelListTarget()");

        return data;
      } else {
        var data = jsonDecode(res.body);
        print("Api.dart - get_mntModelListTarget() : $data");
        return data;
      }
    } catch (e) {
      debugPrint('Api.dart - get_mntModelListTarget() : ' + e.toString());
      //return [];
      return {
        "success": false,
        "message": "Failed to read database table",
        "error": e.toString(),
        "data": [],
      };
    }
  }

  get_mntRegionListActual() async {
    // String uriParam = "?month=$currMonth&year=$currYear";
    String uriParam = "?month=$currMonth&year=$currYear";

    try {
      final token = await getStoredToken();
      final res = await _client
          .get(
            Uri.parse(
              baseUrl + "registration/month/region/list_actual" + uriParam,
            ),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print("Api.dart - get_mntRegionListActual()");

        return data;
      } else {
        var data = jsonDecode(res.body);
        print("Api.dart - get_mntRegionListActual() : $data");
        return data;
      }
    } catch (e) {
      debugPrint('Api.dart - get_mntRegionListActual() : ' + e.toString());
      //return [];
      return {
        "success": false,
        "message": "Failed to read database table",
        "error": e.toString(),
        "data": [],
      };
    }
  }

  get_mntRegionListTarget() async {
    // String uriParam = "?month=$currMonth&year=$currYear";
    String uriParam = "?month=$currMonth&year=$currYear";

    try {
      final token = await getStoredToken();
      final res = await _client
          .get(
            Uri.parse(
              baseUrl + "registration/month/region/list_target" + uriParam,
            ),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print("Api.dart - get_mntRegionListTarget()");

        return data;
      } else {
        var data = jsonDecode(res.body);
        print("Api.dart - get_mntRegionListTarget() : $data");
        return data;
      }
    } catch (e) {
      debugPrint('Api.dart - get_mntRegionListTarget() : ' + e.toString());
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
      final token = await getStoredToken();
      final res = await _client
          .get(
            Uri.parse(baseUrl + "registration/mnt_listRegionOutlet" + uriParam),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print("Api.dart - get_RegionListMntRegOutlets(" + regionCode + ")");

        return data;
      } else {
        var data = jsonDecode(res.body);
        print(
          "Api.dart - get_RegionListMntRegOutlets(" + regionCode + ") : $data",
        );
        return data;
      }
    } catch (e) {
      debugPrint(
        'Api.dart - get_RegionListMntRegOutlets(' +
            regionCode +
            ') : ' +
            e.toString(),
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

  get_ModelListOfOutlet(String outletcode) async {
    //List<actTarget> reg_RegionListMntOutlets = [];

    // String uriParam = "?month=$currMonth&year=$currYear";
    String uriParam = "?month=$currMonth&year=$currYear&outletcode=$outletcode";

    try {
      final token = await getStoredToken();
      final res = await _client
          .get(
            Uri.parse(baseUrl + "registration/mnt_listModelOutlet" + uriParam),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
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

  get_BkgModelListOfOutlet(String outletcode) async {
    //List<actTarget> reg_RegionListMntOutlets = [];

    // String uriParam = "?month=$currMonth&year=$currYear";
    String uriParam = "?month=$currMonth&year=$currYear&outletcode=$outletcode";

    try {
      final token = await getStoredToken();
      final res = await _client
          .get(
            Uri.parse(baseUrl + "booking/mnt_listModelOutlet" + uriParam),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print("Api.dart - get_BkgModelListOfOutlet()");

        return data;
      } else {
        var data = jsonDecode(res.body);
        print("Api.dart - get_BkgModelListOfOutlet() : $data");
        return data;
      }
    } catch (e) {
      debugPrint('Api.dart - get_BkgModelListOfOutlet() : ' + e.toString());
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
      final token = await getStoredToken();
      final res = await _client
          .get(
            Uri.parse(
              baseUrl + "registration/mnt_RegionOutletSummary" + uriParam,
            ),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
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
      final token = await getStoredToken();
      final res = await _client
          .get(
            Uri.parse(
              baseUrl + "registration/mnt_outletModelResult" + uriParam,
            ),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
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
      final token = await getStoredToken();
      final res = await _client
          .get(
            Uri.parse(baseUrl + "dashboard/mnt_bkgActual" + uriParam),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
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
      final token = await getStoredToken();
      final res = await _client
          .get(
            Uri.parse(baseUrl + "dashboard/mnt_bkgTarget" + uriParam),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
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
      final token = await getStoredToken();
      final res = await _client
          // .get(Uri.parse(baseUrl + "booking/mnt_ListActual_ora" + uriParam))
          .get(
            Uri.parse(baseUrl + "booking/mnt_ListActual" + uriParam),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 25));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
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
      final token = await getStoredToken();
      final res = await _client
          .get(
            // Uri.parse(baseUrl + "booking/mnt_listRegionOutlet_ora" + uriParam),
            Uri.parse(baseUrl + "booking/mnt_listRegionOutlet" + uriParam),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
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

  get_AckRegistration() async {
    // List<actTarget> reg_RegionListMntOutlets = [];

    // String uriParam = "?month=$currMonth&year=$currYear";
    String uriParam = "";

    try {
      final token = await getStoredToken();
      final res = await _client
          .get(
            Uri.parse(baseUrl + "dashboard/ack_registration" + uriParam),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print("Api.dart - get_AckRegistration() result : $data");

        return data;
      } else {
        var data = jsonDecode(res.body);
        print("Api.dart - get_AckRegistration() : $data");
        return data;
      }
    } catch (e) {
      debugPrint('Api.dart - get_AckRegistration() : ' + e.toString());
      //return [];
      return {
        "success": false,
        "message": "Failed to read database table",
        "error": e.toString(),
        "data": [],
      };
    }
  }

  get_AckRegistrationOutlet(String outletcode) async {
    // String uriParam = "?month=$currMonth&year=$currYear";
    String uriParam = "?outletcode=$outletcode";

    try {
      final token = await getStoredToken();
      final res = await _client
          .get(
            Uri.parse(baseUrl + "dashboard/ack_registration_outlet" + uriParam),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print("Api.dart - get_AckRegistrationOutlet() : success");

        return data;
      } else {
        var data = jsonDecode(res.body);
        print("Api.dart - get_AckRegistrationOutlet() : $data");
        return data;
      }
    } catch (e) {
      debugPrint('Api.dart - get_AckRegistrationOutlet() : ' + e.toString());
      //return [];
      return {
        "success": false,
        "message": "Failed to read database table",
        "error": e.toString(),
        "data": [],
      };
    }
  }

  get_AckRegistrationOutletList() async {
    // String uriParam = "?month=$currMonth&year=$currYear";
    // String uriParam = "?outletcode=$outletcode";
    String uriParam = "";

    try {
      final token = await getStoredToken();
      final res = await _client
          .get(
            Uri.parse(
              baseUrl + "dashboard/ack_registration_list_outlet" + uriParam,
            ),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print("Api.dart - get_AckRegistrationOutletList() : success");

        return data;
      } else {
        var data = jsonDecode(res.body);
        print("Api.dart - get_AckRegistrationOutletList() : $data");
        return data;
      }
    } catch (e) {
      debugPrint(
        'Api.dart - get_AckRegistrationOutletList() : ' + e.toString(),
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

  get_AckRegistrationRegion() async {
    // String uriParam = "?month=$currMonth&year=$currYear";
    // String uriParam = "?outletcode=$outletcode";
    String uriParam = "";

    try {
      final token = await getStoredToken();
      final res = await _client
          .get(
            Uri.parse(baseUrl + "dashboard/ack_registration_region" + uriParam),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print("Api.dart - get_AckRegistrationRegion() : success");

        return data;
      } else {
        var data = jsonDecode(res.body);
        print("Api.dart - get_AckRegistrationRegion() : $data");
        return data;
      }
    } catch (e) {
      debugPrint('Api.dart - get_AckRegistrationRegion() : ' + e.toString());
      //return [];
      return {
        "success": false,
        "message": "Failed to read database table",
        "error": e.toString(),
        "data": [],
      };
    }
  }

  get_AckRegistrationModel() async {
    // String uriParam = "?month=$currMonth&year=$currYear";
    // String uriParam = "?outletcode=$outletcode";
    String uriParam = "";

    try {
      final token = await getStoredToken();
      final res = await _client
          .get(
            Uri.parse(baseUrl + "dashboard/ack_registration_model" + uriParam),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print("Api.dart - get_AckRegistrationModel() : success");

        return data;
      } else {
        var data = jsonDecode(res.body);
        print("Api.dart - get_AckRegistrationModel() : $data");
        return data;
      }
    } catch (e) {
      debugPrint('Api.dart - get_AckRegistrationModel() : ' + e.toString());
      //return [];
      return {
        "success": false,
        "message": "Failed to read database table",
        "error": e.toString(),
        "data": [],
      };
    }
  }

  get_AckRegistrationModelByOutlet(String outletcode) async {
    String uriParam = "?outletcode=$outletcode";

    try {
      final token = await getStoredToken();
      final res = await _client
          .get(
            Uri.parse(
              baseUrl + "dashboard/ack_registration_model_outlet" + uriParam,
            ),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      ;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print("Api.dart - get_AckRegistrationModelByOutlet() : success");

        return data;
      } else {
        var data = jsonDecode(res.body);
        print("Api.dart - get_AckRegistrationModelByOutlet() : $data");
        return data;
      }
    } catch (e) {
      debugPrint(
        'Api.dart - get_AckRegistrationModelByOutlet() : ' + e.toString(),
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

  //
  //
}
