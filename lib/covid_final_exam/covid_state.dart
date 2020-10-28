import 'package:equatable/equatable.dart';

class CovidState extends Equatable {
  final List<CovidCountryInfo> listCountryInfo;
  final CovidCountryInfo info;
  final CovidCountryInfo globalInfo;
  final bool isConnectInternet;

  CovidState({
    this.listCountryInfo,
    this.info,
    this.globalInfo,
    this.isConnectInternet,
  });

  CovidState copyWith({
    List<CovidCountryInfo> listCountryInfo,
    CovidCountryInfo info,
    CovidCountryInfo globalInfo,
    bool isConnectInternet,
  }) =>
      CovidState(
        listCountryInfo: listCountryInfo,
        info: info,
        globalInfo: globalInfo,
        isConnectInternet: isConnectInternet,
      );

  @override
  // TODO: implement props
  List<Object> get props => [listCountryInfo, info, globalInfo, isConnectInternet];

  @override
  bool operator ==(Object other) {
    if (props == null || props.isEmpty) {
      return false;
    }
    return super == other;
  }

  @override
  bool get stringify {
    return true;
  }

  @override
  int get hashCode {
    return super.hashCode;
  }
}

class CovidCountryInfo {
  final String country;
  final String countryCode;
  final String slug;
  final String newConfirmed;
  final String totalConfirmed;
  final String newDeaths;
  final String totalDeaths;
  final String newRecovered;
  final String totalRecovered;
  final String date;
  CovidCountryInfo(
    this.country,
    this.countryCode,
    this.slug,
    this.newConfirmed,
    this.totalConfirmed,
    this.newDeaths,
    this.totalDeaths,
    this.newRecovered,
    this.totalRecovered,
    this.date
  );

  dynamic operator [](String name) {
    switch(name) {
      case 'country': return country;
      case 'countryCode': return countryCode;
      case 'slug': return slug;
      case 'newConfirmed': return newConfirmed;
      case 'totalConfirmed': return totalConfirmed;
      case 'newDeaths': return newDeaths;
      case 'totalDeaths': return totalDeaths;
      case 'newRecovered': return newRecovered;
      case 'totalRecovered': return totalRecovered;
      case 'date': return date;
      default: throw "no such property: $name";
    }
  }
}
