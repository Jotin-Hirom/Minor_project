class Env {
  static late String apiBaseUrl;
  static late bool isProduction;
  static Future<void> load() async {
    // isProduction = kReleaseMode;

    // apiBaseUrl = isProduction
    //     ? "https://api.classqr.com"         // <-- PROD URL
    //     : "http://localhost:3000";          // <-- DEV URL

    apiBaseUrl = "http://localhost:5000";
  }
}
