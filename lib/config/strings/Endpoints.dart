/*
String endpoint(String url, [
  String status = "", String env = 'TEST']){ //////////////

  if(env == 'TEST'){
    return (TEST_URL + url);
  }
  return (LIVE_URL + url);
}
*/

String endpoint(String url, [
  String status = "", String env = 'TEST']){ //////////////
  Map<String, dynamic> api = {
    "TEST": "http://10.0.2.2:8000/api",
    "LIVE": "https://v2.jollofradio.com/api"
  };

  return api[env] + url;

}

//USER
const USER_SIGNIN_ROUTE = '/user/login';
const USER_SIGNUP_ROUTE = '/user/register';
const USER_ONBOARD_ROUTE = '/user/onboard';
const USER_PROFILE_ROUTE = '/user/profile';
const USER_SERVICE_ROUTE = '/user/service';
const USER_LOGOUT_ROUTE = '/user/logout';
const USER_NOTIFICATION_ROUTE = '/user/notification';
const USER_STREAM_ROUTE = '/user/streams';
const USER_PLAYLIST_ROUTE = '/user/playlist';
const USER_SUBSCRIPTION_ROUTE = '/user/subscriptions';

//CREATOR
const CREATOR_SIGNIN_ROUTE = '/creator/login';
const CREATOR_SIGNUP_ROUTE = '/creator/register';
const CREATOR_PROFILE_ROUTE = '/creator/profile';
const CREATOR_SERVICE_ROUTE = '/creator/service';
const CREATOR_LOGOUT_ROUTE = '/creator/logout';
const CREATOR_NOTIFICATION_ROUTE = '/creator/notification';

//SERVICE
const CATEGORY_ROUTE = '/services/category';
const SEARCH_ROUTE = '/services/search';
const INTEREST_ROUTE = '/services/interests';
const STATIONS_ROUTE = '/services/stations';
const PODCASTS_ROUTE = '/services/podcasts';

///////////////////////////////////////////////////////////