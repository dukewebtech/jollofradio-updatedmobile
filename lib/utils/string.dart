class Str {

  static String substr(String string, s,l){
    int start = string.length  >= s ? s : 0;
    int length = string.length >= l ? l : 
    string.length;

    return string.substring(start, length);
  }

  static String toLowerCase(String string){

    return string.toLowerCase();

  }

  static String toUpperCase(String string){

    return string.toUpperCase();
    
  }

  static String capitalize(String string){
    string = string.toLowerCase();
    
    String firstWord = string.substring(0, 1);
    firstWord = firstWord.toUpperCase();

    return firstWord+string.substring(1);
    
  }

}