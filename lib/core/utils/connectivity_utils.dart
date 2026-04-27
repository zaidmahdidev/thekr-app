import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityUtils {
  static Future<bool> hasInternet() async {
    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }
    return true;
  }
}
