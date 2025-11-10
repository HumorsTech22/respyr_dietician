class UrlManager {
  final String companyDomain = "https://humorstech.com/humors_app/app_final/dieticianapp/";

  late final String urlSaveFcmToken;
  late final String urlGetTestLogStatus;
  late final String urlSaveTestLog;
  late final String urlCreateClientProfile;
  late final String urlGetDietitianDetails;

  UrlManager() {
    urlSaveFcmToken = "${companyDomain}api/insert_fcm_token.php";
    urlGetTestLogStatus = "${companyDomain}api/get_test_log_status.php";
    urlSaveTestLog = "${companyDomain}api/insert_test_log.php";
    urlCreateClientProfile = "${companyDomain}api/create_client.php";
    urlGetDietitianDetails = "${companyDomain}api/get_dietician.php";
  }
}
