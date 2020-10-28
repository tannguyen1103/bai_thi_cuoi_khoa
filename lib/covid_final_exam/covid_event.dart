import 'package:bai_thi_cuoi_khoa/covid_final_exam/covid_state.dart';
import 'package:equatable/equatable.dart';

abstract class CovidEvent extends Equatable{
  @override
  List<Object> get props => [];
}
// ignore: must_be_immutable
class InitialEvent extends CovidEvent {}

class SearchCountryByCountryNameEvent extends CovidEvent {
  final String countryName;

  SearchCountryByCountryNameEvent(this.countryName);
}

class GetCountrySumaryOnTapEvent extends CovidEvent{
  final CovidCountryInfo info;

  GetCountrySumaryOnTapEvent(this.info);
}

// class CheckConnectInternetEvent extends CovidEvent{}