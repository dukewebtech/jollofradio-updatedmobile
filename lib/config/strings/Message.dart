// ignore_for_file: non_constant_identifier_names

class Message {

  static String splash = "Explore, create, learn, have fun";
  static String splash_message = "Experience Jollof Radio: Where Podcasters, Listeners, and Advertisers Connect for Great Entertainment and Mutual Benefits";
  static String startup_heading = "How do you want to Sign Up?";
  static String forgot_password = "Hang on captain! it happens sometimes. Let's get you back to your account";
  static String verify_code = "We sent an OTP to your email to confirm it's you. Enter to reset password";
  static String reset_password = "😉 Almost there. Now choose a strong password you can always remember";
  static String verify_account = "You're almost there. Kindly verify your email to continue. Didnt get an email? We can send you a new verification link right away";
  static String no_activity = "You dont have any activities at the moment. keep exploring...";
  static String no_data = "We have nothing to show at the moment, try again later";
  static String no_playlist = "You don't have any playlist at the moment. start buzzing!";
  static String no_desc = "No description currently available on this podcast at the moment";
  static String launch = "We're developing an amazing product that will change your podcast game.";
  static String launch_message = "Earn amazing prices or get paid instantly to advertise on your podcasts, for companies worldwide via the JollofRadio monetization program";
  static String publish_note = "You can choose to import your podcast from existing platform or upload manually. Uploads will be reviewed before being published.";
  static String upload_note = "Set up your podcast channel, add to a category and write a description, save it and your are ready to add your audio file";
  static String import_note = "Import your podcast from existing platform via RSS. Your uploads will be reviewed before being published.";
  static String episode_note = "You can choose to upload an episode from URL (.mp3) or upload manually. Uploads will be reviewed before being published.";
  static String delete_item = "Are you sure you want to delete this #item from your #source?";
  static String enrolled = "Nice! You've been enrolled to the monetization beta program. You'll be preinformed before the launch.";
  static String share_podcast = "Listen to: #title on Jollof Radio at https://share.jollofradio.com/podcast/#podcast";
  static String share_episode = "Listen to: #title on Jollof Radio at https://share.jollofradio.com/episode/#episode";
  static String share_station = "Listen to: #title on Jollof Radio at https://share.jollofradio.com/station/#station";
  static String password_invalid = "Password should contain Capital, small letter, Number & Special characters";


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