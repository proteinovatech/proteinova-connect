abstract class CustomerTrayEvent {}

class FetchCustomerTraysEvent extends CustomerTrayEvent {
  final String search;

  FetchCustomerTraysEvent({this.search = ''});
}