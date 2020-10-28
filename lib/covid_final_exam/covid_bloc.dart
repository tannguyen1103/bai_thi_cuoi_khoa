import 'package:bai_thi_cuoi_khoa/covid_final_exam/covid_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:tiengviet/tiengviet.dart';
import 'dart:convert' as convert;
import 'package:connectivity/connectivity.dart';

import 'covid_state.dart';

class CovidBloc extends Bloc<CovidEvent, CovidState> {
  CovidBloc() : super(CovidState(listCountryInfo: null)) {}
  List<CovidCountryInfo> fullList;
  List<CovidCountryInfo> curList;
  CovidCountryInfo curInfo;
  CovidCountryInfo globalInfo;

  Future<CovidCountryInfo> _getGlobalInfo() async {
    final url = "https://api.covid19api.com/summary";
    var response = await get(url);
    var jsonResponse = convert.jsonDecode(response.body);
    CovidCountryInfo globalInfo = CovidCountryInfo(
        "Global (Thế giới)",
        "GL",
        "GL",
        jsonResponse["Global"]["NewConfirmed"].toString(),
        jsonResponse["Global"]["TotalConfirmed"].toString(),
        jsonResponse["Global"]["NewDeaths"].toString(),
        jsonResponse["Global"]["TotalDeaths"].toString(),
        jsonResponse["Global"]["NewRecovered"].toString(),
        jsonResponse["Global"]["TotalRecovered"].toString(),
        jsonResponse["Global"]["Date"].toString());
    return globalInfo;
  }

  Future<CovidCountryInfo> _getCountryInfo(String country) async {
    final url = "https://api.covid19api.com/summary";
    var response = await get(url);
    var jsonResponse = convert.jsonDecode(response.body);
    var lsCountrySumary = jsonResponse["Countries"] as List;
    CovidCountryInfo covid = null;
    String countryTransalte = "";
    for (int i = 0; i < lsCountrySumary.length; i++) {
      countryTransalte = lsCountrySumary[i]["Country"] +
          " (" +
          mapCountry[(lsCountrySumary[i]["Country"])] +
          ")";
      if (countryTransalte
          .toLowerCase()
          .trim()
          .contains(country.trim().toLowerCase())) {
        covid = CovidCountryInfo(
            countryTransalte,
            lsCountrySumary[i]["CountryCode"],
            lsCountrySumary[i]["Slug"],
            lsCountrySumary[i]["NewConfirmed"].toString(),
            lsCountrySumary[i]["TotalConfirmed"].toString(),
            lsCountrySumary[i]["NewDeaths"].toString(),
            lsCountrySumary[i]["TotalDeaths"].toString(),
            lsCountrySumary[i]["NewRecovered"].toString(),
            lsCountrySumary[i]["TotalRecovered"].toString(),
            lsCountrySumary[i]["Date"].toString());
        break;
      }
    }
    return covid;
  }

  Future<List<CovidCountryInfo>> _getSumaryAllCountry() async {
    final url = "https://api.covid19api.com/summary";
    var response = await get(url);
    var jsonResponse = convert.jsonDecode(response.body);
    List<CovidCountryInfo> ls = List<CovidCountryInfo>();
    var lsCountrySumary = jsonResponse["Countries"] as List;
    String countryTransalte = "";
    for (int i = 0; i < lsCountrySumary.length; i++) {
      countryTransalte = lsCountrySumary[i]["Country"] +
          " (" +
          mapCountry[(lsCountrySumary[i]["Country"])] +
          ")";
      CovidCountryInfo covid = CovidCountryInfo(
          //lsCountrySumary[i]["Country"],
          countryTransalte,
          lsCountrySumary[i]["CountryCode"],
          lsCountrySumary[i]["Slug"],
          lsCountrySumary[i]["NewConfirmed"].toString(),
          lsCountrySumary[i]["TotalConfirmed"].toString(),
          lsCountrySumary[i]["NewDeaths"].toString(),
          lsCountrySumary[i]["TotalDeaths"].toString(),
          lsCountrySumary[i]["NewRecovered"].toString(),
          lsCountrySumary[i]["TotalRecovered"].toString(),
          lsCountrySumary[i]["Date"].toString());

      // print(covid.map["Japan"]);
      ls.add(covid);
    }
    return ls;
  }

  Future<List<CovidCountryInfo>> _getListCountryByName(
      String countryName) async {
    print("_getListCountryByName ");
    if (fullList == null) {
      final url = "https://api.covid19api.com/summary";
      var response = await get(url);
      var jsonResponse = convert.jsonDecode(response.body);
      var curList = jsonResponse["Countries"] as List;
    }
    //String countryTransalte = "";
    List<CovidCountryInfo> ls = List<CovidCountryInfo>();
    for (int i = 0; i < fullList.length; i++) {
      // print(fullList.length.toString());
      // print(fullList[i].country + '- ' + fullList[i].slug);
      if (TiengViet.parse(fullList[i].country.toLowerCase().trim())
          .contains(TiengViet.parse(countryName.trim().toLowerCase()))) {
        CovidCountryInfo covid = CovidCountryInfo(
            fullList[i].country,
            fullList[i].countryCode,
            fullList[i].slug,
            fullList[i].newConfirmed,
            fullList[i].totalConfirmed,
            fullList[i].newDeaths,
            fullList[i].totalDeaths,
            fullList[i].newRecovered,
            fullList[i].totalRecovered,
            fullList[i].date);
        ls.add(covid);
      }
      // print(ls.length);
    }
    return ls;
  }

  @override
  Stream<CovidState> mapEventToState(CovidEvent event) async* {
    switch (event.runtimeType) {
      // case CheckConnectInternetEvent:
      //   var connectivityResult = await (Connectivity().checkConnectivity());
      //   bool isConnect = false;
      //   if (connectivityResult != ConnectivityResult.none) isConnect = true;
      //   yield state.copyWith(
      //     isConnectInternet: isConnect,
      //   );
      //   break;
      case InitialEvent:
        var connectivityResult = await (Connectivity().checkConnectivity());
        //print("Kết nối mạng: " + connectivityResult.toString());
        if (connectivityResult != ConnectivityResult.none) {
          //print("Có kết nối mạng");
          globalInfo = await _getGlobalInfo();
          curInfo = await _getCountryInfo('Viet Nam (Việt Nam)');
          curList = fullList = await _getSumaryAllCountry();
          yield state.copyWith(
            isConnectInternet: true,
            info: curInfo,
            listCountryInfo: curList,
            globalInfo: globalInfo,
          );
        }
        else
          yield state.copyWith(
            isConnectInternet: false,
          );
        break;
      case SearchCountryByCountryNameEvent:
        globalInfo = await _getGlobalInfo();
        final a = event as SearchCountryByCountryNameEvent;
        curList = await _getListCountryByName(a.countryName);
        yield state.copyWith(
          info: curInfo,
          listCountryInfo: curList,
          globalInfo: globalInfo,
        );
        break;
      case GetCountrySumaryOnTapEvent:
        globalInfo = await _getGlobalInfo();
        final a = event as GetCountrySumaryOnTapEvent;
        yield state.copyWith(
          info: a.info,
          listCountryInfo: curList,
          globalInfo: globalInfo,
        );
        break;
      default:
        break;
    }
  }
}


Map<String, String> mapCountry = {
  'Afghanistan': 'Afghanistan',
  'Albania': 'Albania',
  'Algeria': 'Algeria',
  'Andorra': 'Andorra',
  'Angola': 'Angola',
  'Antigua and Barbuda': 'Antigua và Barbuda',
  'Argentina': 'Argentina',
  'Armenia': 'Armenia',
  'Australia': 'Úc',
  'Austria': 'Áo',
  'Azerbaijan': 'Azerbaijan',
  'Bahamas': 'Bahamas',
  'Bahrain': 'Bahrain',
  'Bangladesh': 'Bangladesh',
  'Barbados': 'Barbados',
  'Belarus': 'Belarus',
  'Belgium': 'Bỉ',
  'Belize': 'Belize',
  'Benin': 'Benin',
  'Bhutan': 'Bhutan',
  'Bolivia': 'Bolivia',
  'Bosnia and Herzegovina': 'Bosnia và Herzegovina',
  'Botswana': 'Botswana',
  'Brazil': 'Brazil',
  'Brunei Darussalam': 'Vương quốc Bru-nây',
  'Bulgaria': 'Bungari',
  'Burkina Faso': 'Burkina Faso',
  'Burundi': 'Burundi',
  'Cambodia': 'Campuchia',
  'Cameroon': 'Cameroon',
  'Canada': 'Canada',
  'Cape Verde': 'Cape Verde',
  'Central African Republic': 'Cộng hòa Trung Phi',
  'Chad': 'Chad',
  'Chile': 'Chile',
  'China': 'Trung Quốc',
  'Colombia': 'Colombia',
  'Comoros': 'Comoros',
  'Congo (Brazzaville)': 'Congo (Brazzaville)',
  'Congo (Kinshasa)': 'Congo (Kinshasa)',
  'Costa Rica': 'Costa Rica',
  'Croatia': 'Croatia',
  'Cuba': 'Cuba',
  'Cyprus': 'Síp',
  'Czech Republic': 'Cộng hòa Séc',
  'Côte d\'Ivoire': 'Côte d\'Ivoire',
  'Denmark': 'Đan mạch',
  'Djibouti': 'Djibouti',
  'Dominica': 'Dominica',
  'Dominican Republic': 'Cộng hòa Dominica',
  'Ecuador': 'Ecuador',
  'Egypt': 'Ai cập',
  'El Salvador': 'El Salvador',
  'Equatorial Guinea': 'Equatorial Guinea',
  'Eritrea': 'Eritrea',
  'Estonia': 'Estonia',
  'Ethiopia': 'Ethiopia',
  'Fiji': 'Fiji',
  'Finland': 'Phần Lan',
  'France': 'pháp',
  'Gabon': 'Gabon',
  'Gambia': 'Gambia',
  'Georgia': 'Georgia',
  'Germany': 'Đức',
  'Ghana': 'Ghana',
  'Greece': 'Hy Lạp',
  'Grenada': 'Grenada',
  'Guatemala': 'Guatemala',
  'Guinea': 'Guinea',
  'Guinea-Bissau': 'Guinea-Bissau',
  'Guyana': 'Guyana',
  'Haiti': 'Haiti',
  'Holy See (Vatican City State)': 'Holy See (Nhà nước thành phố Vatican)',
  'Honduras': 'Honduras',
  'Hungary': 'Hungary',
  'Iceland': 'Iceland',
  'India': 'Ấn Độ',
  'Indonesia': 'Indonesia',
  'Iran, Islamic Republic of': 'Iran (Cộng hòa Hồi giáo)',
  'Iraq': 'Iraq',
  'Ireland': 'Ireland',
  'Israel': 'Người israel',
  'Italy': 'Ý',
  'Jamaica': 'Jamaica',
  'Japan': 'Nhật Bản',
  'Jordan': 'Jordan',
  'Kazakhstan': 'Kazakhstan',
  'Kenya': 'Kenya',
  'Korea (South)': 'Nam Triều Tiên)',
  'Kuwait': 'Kuwait',
  'Kyrgyzstan': 'Kyrgyzstan',
  'Lao PDR': 'CHDCND Lào',
  'Latvia': 'Latvia',
  'Lebanon': 'Lebanon',
  'Lesotho': 'Lesotho',
  'Liberia': 'Liberia',
  'Libya': 'Libya',
  'Liechtenstein': 'Liechtenstein',
  'Lithuania': 'Lithuania',
  'Luxembourg': 'Luxembourg',
  'Macao, SAR China': 'Macao, SAR Trung Quốc',
  'Macedonia, Republic of': 'Macedonia, Cộng hòa',
  'Madagascar': 'Madagascar',
  'Malawi': 'Malawi',
  'Malaysia': 'Malaysia',
  'Maldives': 'Maldives',
  'Mali': 'Mali',
  'Malta': 'Malta',
  'Mauritania': 'Mauritania',
  'Mauritius': 'Mauritius',
  'Mexico': 'Mexico',
  'Moldova': 'Moldova',
  'Monaco': 'Monaco',
  'Mongolia': 'Mông Cổ',
  'Montenegro': 'Montenegro',
  'Morocco': 'Maroc',
  'Mozambique': 'Mozambique',
  'Myanmar': 'Myanmar',
  'Namibia': 'Namibia',
  'Nepal': 'Nepal',
  'Netherlands': 'Hà Lan',
  'New Zealand': 'New Zealand',
  'Nicaragua': 'Nicaragua',
  'Niger': 'Niger',
  'Nigeria': 'Nigeria',
  'Norway': 'Na Uy',
  'Oman': 'Oman',
  'Pakistan': 'Pakistan',
  'Palestinian Territory': 'Lãnh thổ của người Palestin',
  'Panama': 'Panama',
  'Papua New Guinea': 'Papua New Guinea',
  'Paraguay': 'Paraguay',
  'Peru': 'Peru',
  'Philippines': 'Philippines',
  'Poland': 'Ba lan',
  'Portugal': 'Bồ Đào Nha',
  'Qatar': 'Qatar',
  'Republic of Kosovo': 'Cộng hòa Kosovo',
  'Romania': 'Romania',
  'Russian Federation': 'Liên bang Nga',
  'Rwanda': 'Rwanda',
  'Réunion': 'Réunion',
  'Saint Kitts and Nevis': 'Saint Kitts và Nevis',
  'Saint Lucia': 'Saint Lucia',
  'Saint Vincent and Grenadines': 'Saint Vincent và Grenadines',
  'San Marino': 'San Marino',
  'Sao Tome and Principe': 'Sao Tome và Principe',
  'Saudi Arabia': 'Ả Rập Saudi',
  'Senegal': 'Senegal',
  'Serbia': 'Serbia',
  'Seychelles': 'Seychelles',
  'Sierra Leone': 'Sierra Leone',
  'Singapore': 'Singapore',
  'Slovakia': 'Xlô-va-ki-a',
  'Slovenia': 'Slovenia',
  'Solomon Islands': 'Quần đảo Solomon',
  'Somalia': 'Somalia',
  'South Africa': 'Nam Phi',
  'South Sudan': 'phía nam Sudan',
  'Spain': 'Tây ban nha',
  'Sri Lanka': 'Sri Lanka',
  'Sudan': 'Sudan',
  'Suriname': 'Suriname',
  'Swaziland': 'Swaziland',
  'Sweden': 'Thụy Điển',
  'Switzerland': 'Thụy sĩ',
  'Syrian Arab Republic (Syria)': 'Cộng hòa Ả Rập Syria (Syria)',
  'Taiwan, Republic of China': 'Đài Loan, Trung Hoa Dân Quốc',
  'Tajikistan': 'Tajikistan',
  'Tanzania, United Republic of': 'Tanzania, Cộng hòa Thống nhất',
  'Thailand': 'Thái Lan',
  'Timor-Leste': 'Timor-Leste',
  'Togo': 'Togo',
  'Trinidad and Tobago': 'Trinidad và Tobago',
  'Tunisia': 'Tunisia',
  'Turkey': 'Thổ Nhĩ Kỳ',
  'Uganda': 'Uganda',
  'Ukraine': 'Ukraine',
  'United Arab Emirates': 'Các Tiểu Vương Quốc Ả Rập Thống Nhất',
  'United Kingdom': 'Vương quốc Anh',
  'United States of America': 'Mỹ',
  'Uruguay': 'Uruguay',
  'Uzbekistan': 'Uzbekistan',
  'Venezuela (Bolivarian Republic)': 'Venezuela (Cộng hòa Bolivar)',
  'Viet Nam': 'Việt Nam',
  'Western Sahara': 'Tây Sahara',
  'Yemen': 'Yemen',
  'Zambia': 'Zambia',
  'Zimbabwe': 'Zimbabwe'
};