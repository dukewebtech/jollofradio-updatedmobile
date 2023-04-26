import 'package:intl/intl.dart';

class Date {
  late String date;
  int? timestamp;

  Date([String? date]){

    this.date = date 
    ?? DateTime.now().toString();
    
    timestamp = DateTime.parse(format( )).millisecondsSinceEpoch;
  
  }

  String timezone(){
    var getHourly = (int.parse(
      format("HH")
    ));

    if( getHourly >= 0  && getHourly <  12) return ('Morning');
    if( getHourly >= 12 && getHourly <  17) return ('Afternoon');
    if( getHourly >= 17 && getHourly <  19) return ('Evening');
    if( getHourly >= 19 && getHourly != 00) return ('Evening');

    return "Day";
  }

  String format([String? format]){
    String getDate = DateFormat(format ?? 'y-MM-dd HH:mm').format(
      DateTime.parse(date)
    );
    return getDate;
  }
}
