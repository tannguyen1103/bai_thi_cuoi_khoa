import 'package:bai_thi_cuoi_khoa/covid_final_exam/covid_bloc.dart';
import 'package:bai_thi_cuoi_khoa/covid_final_exam/covid_event.dart';
import 'package:bai_thi_cuoi_khoa/covid_final_exam/covid_state.dart';
import 'package:bai_thi_cuoi_khoa/global.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'dart:convert' as convert;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flushbar/flushbar.dart';

class CovidWidget extends StatefulWidget {
  @override
  _CovidWidgetState createState() => _CovidWidgetState();
}

class _CovidWidgetState extends State<CovidWidget> {
  Bloc bloc;
  DateTime lastInput = DateTime.now();
  FocusNode _focusNode;
  TextEditingController _textEditingController = TextEditingController();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  @override
  void initState() {
    super.initState();
    bloc = CovidBloc();
    bloc.add(InitialEvent());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: blueColor,
        body: BlocBuilder<CovidBloc, CovidState>(
          cubit: bloc,
          builder: (context, state) {
            // print("Trang thai ket noi: " + state.isConnectInternet.toString());
            return _buildBody(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, CovidState state) {
    if (state.isConnectInternet == false)
      return Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/no-internet.png'),
            SizedBox(
              height: 10,
            ),
            Text(
              "Kiểm tra kết nối Internet, bấm reload để thử lại",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow,
                  fontSize: 18),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: 30,
              child: FloatingActionButton(
                backgroundColor: Colors.transparent,
                onPressed: () {
                  Flushbar(
                    title:  "Thông báo",
                    message:  "Hệ thống đang tải dữ liệu, vui lòng đợi trong giây lát",
                    duration:  Duration(seconds: 3),
                    margin: EdgeInsets.all(8),
                    borderRadius: 8,
                  )..show(context);
                  bloc.add(InitialEvent());
                  _textEditingController.text = "";
                },
                child: new Icon(Icons.refresh),
              ),
            ),
          ],
        ),
      );
    else
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: (state.globalInfo == null)
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 6,
                ),
              )
            : Column(
                children: [
                  Flexible(
                    flex: 75,
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Thông tin Covid 19",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                width: 25,
                                child: FloatingActionButton(
                                  backgroundColor: Colors.transparent,
                                  onPressed: () {
                                    bloc.add(InitialEvent());
                                    _textEditingController.text = "";
                                    FocusScope.of(context).unfocus();
                                    Flushbar(
                                      title:  "Thông báo",
                                      message:  "Hệ thống đang tải dữ liệu, vui lòng đợi trong giây lát",
                                      duration:  Duration(seconds: 3),
                                      margin: EdgeInsets.all(8),
                                      borderRadius: 8,
                                    )..show(context);
                                  },
                                  child: new Icon(Icons.refresh),
                                ),
                              ),
                            ],
                          ),
                          if (state.globalInfo != null)
                            _buildGlobal(state.globalInfo),
                          if (state.info != null) _buildCountryInfo(state.info),
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            padding: EdgeInsets.all(15.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Column(
                              children: [
                                TextField(
                                  controller: _textEditingController,
                                  decoration: InputDecoration(
                                    hintText: "Tìm theo tên nước",
                                    suffixIcon: IconButton(
                                      onPressed: () => {
                                        Flushbar(
                                          title:  "Thông báo",
                                          message:  "Hệ thống đang tìm kiếm, vui lòng đợi trong giây lát",
                                          duration:  Duration(seconds: 3),
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          )..show(context),
                                        print(_textEditingController.text),
                                        bloc.add(
                                            SearchCountryByCountryNameEvent(
                                                _textEditingController.text)),
                                        FocusScope.of(context).unfocus(),
                                      },
                                      icon: Icon(Icons.search),
                                    ),
                                    //icon: Icon(Icons.search)
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 64,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25.0),
                            topRight: Radius.circular(25.0),
                          ),
                          color: Colors.white),
                      padding: EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Danh sách các quốc gia",
                                style: TextStyle(
                                  color: Color(0xff0b1666),
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: ListView(
                              children: [
                                if (state.listCountryInfo.length>0)
                                  for (CovidCountryInfo item
                                      in state.listCountryInfo)
                                    _buildListCountryItem(item)
                                else
                                  Center(child: Text("Không có dữ liệu phù hợp"))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      );
  }

  _buildGlobal(CovidCountryInfo info) {
    return Container(
      margin: EdgeInsets.only(top: 5),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                "images/global.png",
                width: 25,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                info.country.toString(),
                style: Theme.of(context).textTheme.title,
              ),
            ],
          ),
          LayoutBuilder(
            builder: (ctx, constraints) {
              return Wrap(
                runSpacing: 5,
                children: List.generate(
                  6,
                  (f) {
                    return Container(
                      width: constraints.maxWidth / 3,
                      child: Row(
                        children: [
                          Container(
                            width: 7,
                            height: 22,
                            decoration: BoxDecoration(
                              color: covidStateList[f]['color'],
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          SizedBox(width: 5.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(covidStateList[f]['name'].toString()),
                              Text(
                                info[covidStateList[f]['state']],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  _buildCountryInfo(CovidCountryInfo info) {
    return Container(
      margin: EdgeInsets.only(top: 5),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (info.country != "Global (Thế giới)")
                Image.network(
                  "https://www.countryflags.io/" +
                      info.countryCode.toString() +
                      "/shiny/64.png",
                  width: 25,
                ),
              SizedBox(
                width: 5,
              ),
              Text(
                info.country.toString(),
                style: Theme.of(context).textTheme.title,
              ),
            ],
          ),
          LayoutBuilder(
            builder: (ctx, constraints) {
              return Wrap(
                runSpacing: 5,
                children: List.generate(
                  6,
                  (f) {
                    return Container(
                      width: constraints.maxWidth / 3,
                      child: Row(
                        children: [
                          Container(
                            width: 7,
                            height: 22,
                            decoration: BoxDecoration(
                              color: covidStateList[f]['color'],
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          SizedBox(width: 5.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(covidStateList[f]['name'].toString()),
                              Text(
                                info[covidStateList[f]['state']],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  _buildListCountryItem(CovidCountryInfo info) {
    return ListTile(
      onTap: () {
        FocusScope.of(context).unfocus();
        //bloc.add(GetCountrySumaryOnTapEvent(info));
      },
      leading: Container(
        padding: EdgeInsets.all(0.0),
        decoration: BoxDecoration(
          color: CupertinoColors.lightBackgroundGray,
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25.0),
          // child: Image.network(
          //   "https://www.countryflags.io/" +
          //       info.countryCode.toString() +
          //       "/shiny/64.png",
          //   width: 50,
          // ),
          child: CachedNetworkImage(
            imageUrl: "https://www.countryflags.io/"+info.countryCode.toString() +"/shiny/64.png",
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
            //width: 50,
          ),
        ),
      ),
      title: Text(info.country.toString()),
      subtitle: Text('Mắc: ' +
          info.totalConfirmed.toString() +
          " - Chết: " +
          info.totalDeaths.toString() +
          " - Hồi phục: " +
          info.totalRecovered.toString()),
    );
  }
}
