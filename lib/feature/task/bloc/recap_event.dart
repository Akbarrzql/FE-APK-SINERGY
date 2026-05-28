import 'package:meta/meta.dart';

@immutable
abstract class RecapEvent {}

class FetchRecapData extends RecapEvent {
  final String filterWaktu;

  FetchRecapData({required this.filterWaktu});
}
