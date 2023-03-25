class Factory {
  final List<dynamic> data;

  Factory(this.data);

  List get(int start, [int? limit = 100 /* */]) {

  if(limit != null){
    limit = limit + start;
    if(data.length >= limit){

        return data.sublist(start, limit).toList();

    }    
  }

  return data.sublist(start);
  
}
}