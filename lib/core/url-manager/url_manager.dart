class UrlManager {
  final String companyDomain = "https://humorstech.com/humors_app/app_final/dieticianapp/";

  late final String urlSaveFcmToken;
  late final String urlGetTestLogStatus;
  late final String urlSaveTestLog;

  UrlManager() {
    urlSaveFcmToken = "${companyDomain}api/insert_fcm_token.php";
    urlGetTestLogStatus = "${companyDomain}api/get_test_log_status.php";
    urlSaveTestLog = "${companyDomain}api/insert_test_log.php";
  }
}
