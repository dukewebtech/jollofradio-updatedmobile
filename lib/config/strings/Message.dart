// ignore_for_file: non_constant_identifier_names

class Message {

  static String splash = "Listen on the go";
  static String splash_message = "Listen to people who excite you and make you laugh, cry, take action and more with our delicious podcast app.";
  static String startup_heading = "How do you want to Sign Up?";
  static String forgot_password = "Hang on captain! it happens sometimes. Let's get you back to your account";
  static String verify_code = "We sent an OTP to your email to confirm it's you. Enter to reset password";
  static String reset_password = "😉 Almost there. Now choose a strong password you can always remember";
  static String no_activity = "You dont have any activities at the moment. keep exploring...";
  static String no_data = "We have nothing to show at the moment, try again later";
  static String no_playlist = "You don't have any playlist at the moment. start buzzing!";
  static String launch = "We're developing an amazing product that will change your podcast game.";
  static String launch_message = "Earn amazing prices or get paid instantly to advertise on your podcasts, for companies worldwide via the JollofRadio monetization program";
  static String enrolled = "Nice! You've been enrolled to the monetization beta program. You'll be preinformed before the launch.";
  static String share_podcast = "Listen to: #title on Jollof Radio at https://app.jollofradio.com/podcast/#podcast";
  static String share_episode = "Listen to: #title on Jollof Radio at https://app.jollofradio.com/podcast/#podcast?episode=#episode";
  static String share_station = "Listen to: #title on Jollof Radio at https://app.jollofradio.com/home?station=#station";





  static String build(String message, [Map? data]) {
    if(data != null){
      for (var entry in data.entries) {

        message = message.replaceFirst(
          RegExp('#'+entry.key), entry.value.toString()
        );
        
      }
    }
    
    return message;

  }

}