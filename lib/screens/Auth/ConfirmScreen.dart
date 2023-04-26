import 'package:jollofradio/config/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:jollofradio/config/services/controllers/AuthController.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/config/strings/Message.dart';
import 'package:jollofradio/utils/toaster.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/screens/Layouts/TextInput.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/widget/Labels.dart';

class ConfirmScreen extends StatefulWidget {
  const ConfirmScreen({super.key});

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  bool isLoading = false;
  TextEditingController otp1 = TextEditingController();
  TextEditingController otp2 = TextEditingController();
  TextEditingController otp3 = TextEditingController();
  TextEditingController otp4 = TextEditingController();
  TextEditingController otp5 = TextEditingController();
  late List<TextEditingController> _controllers = [];

  @override
  void initState() {
    _controllers = [
      otp1,
      otp2,
      otp3,
      otp4,
      otp5
    ];

    super.initState();
  }

  Future _doVerify() async {
    String otp = _controllers.map((otp) => otp.text).join(     );
    Map data = {
      "otp": otp
    };

    if(isLoading || otp.isEmpty)
      return;

    setState(() {
      isLoading = true;
    });

    await AuthController.verify(data).then((dynamic data) async {
      
      setState(() {
        isLoading = false;
      });

      if (data['error']){
        _controllers.map(
          (otp)=>otp.clear()
        ).toList();
        
        return Toaster.error(data['message']); //////////////////
      }
  
      RouteGenerator.goto(RESET_PASSWORD, {
        "otp": otp,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(null),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: double.infinity,
        margin: EdgeInsets.only(left: 40, right: 40),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    width: 300,
                    child: Image.asset(
                      "assets/images/illustration/pincode.png"
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Labels.primary(
                  "Confirm OTP",
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
                Labels.secondary(
                  Message.verify_code,
                  fontSize: 13,
                  maxLines: 2
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    ..._controllers.map<Widget>((controller) 
                    => SizedBox(
                        width: 50,
                        child: TextInput(
                          controller: controller,
                          label: "*", 
                          type: TextInputType.number,
                          align: TextAlign.center,
                          action: TextInputAction.next,
                          color: Colors.white,
                          backgroundColor: AppColor.input,
                          borderRadius: 7,
                          onChanged: (value) => {
                            if(value.isNotEmpty && value.length == 1){

                              FocusScope.of(context).nextFocus()

                            }
                          },
                        ),
                      )
                    ).toList()
                  ],
                ),
                Buttons.primary(
                  label: !isLoading ? "Confirm" : "Confirming... ",
                    onTap: () async => await _doVerify(),
                ),
                Center(
                  child: Labels.secondary(
                    "Remember? Sign In",
                    onTap: () => RouteGenerator.goBack(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}