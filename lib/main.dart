import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart'; // dio 라이브러리 추가

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebLayout(),
    );
  }
}

class WebLayout extends StatefulWidget {
  @override
  _WebLayoutState createState() => _WebLayoutState();
}

class _WebLayoutState extends State<WebLayout> {
  // 업종 코드 (UI에 보이지 않음)
  final Map<String, String> businessCodes = {
    '인터넷 정보 매개 서비스업': '642004',
    '컴퓨터 시스템 통합 자문 및 구축 서비스업': '721000',
    '컴퓨터시설 관리업': '721001',
    '응용 소프트웨어 개발 및 공급업': '722000',
    '유선 온라인 게임 소프트웨어 개발 및 공급업': '722001',
    '모바일 게임 소프트웨어 개발 및 공급업': '722002',
    '기타 게임 소프트웨어 개발 및 공급업': '722003',
    '시스템 소프트웨어 개발 및 공급업': '722004',
    '컴퓨터 프로그래밍 서비스업': '722005',
    '자료 처리업': '723000',
    '호스팅 및 관련 서비스업': '723001',
    '데이터베이스 및 온라인 정보 제공업': '724000',
    '그 외 기타 정보 서비스업': '724002',
    '기타 정보 기술 및 컴퓨터 운영 관련 서비스업': '729000',
  };

  // 선택된 코드 리스트
  List<String> selectedCodes = [];

  // 결과 데이터 리스트
  List<String> fetchedData = [];

  // 사업장 정보
  String companyInfo = "";

  // API 호출 (업종 코드에 따른 회사명 목록 가져오기)
  Future<void> fetchData(String code) async {
    final url = Uri.parse(
        'http://a9b8c7d6e5f4g3h2i1j0klmnopqrst.ap-northeast-2.elasticbeanstalk.com/api/getCompanyNames/$code');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          fetchedData = data.map((item) => item.toString()).toList();
        });
      } else {
        print('데이터를 불러오는 데 실패했습니다.');
      }
    } catch (e) {
      print('에러: $e');
    }
  }

  // 사업장 정보 호출 API (업체명 인코딩 처리)
  Future<void> fetchCompanyInfo(String companyName) async {
    final encodedCompanyName = Uri.encodeComponent(companyName);  // Encode the company name
    final url = Uri.parse(
        'http://a9b8c7d6e5f4g3h2i1j0klmnopqrst.ap-northeast-2.elasticbeanstalk.com/$encodedCompanyName');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // Decode the response body and pretty-print it
        var decodedInfo = jsonDecode(response.body);  // Decode the response
        var prettyPrintedInfo = JsonEncoder.withIndent('  ').convert(decodedInfo);  // Pretty-print with 2 spaces

        setState(() {
          companyInfo = prettyPrintedInfo; // Set the formatted info
        });
      } else {
        setState(() {
          companyInfo = '정보를 불러오는 데 실패했습니다.'; // Failure message
        });
      }
    } catch (e) {
      setState(() {
        companyInfo = '에러: $e'; // Error message
      });
    }
  }

  // 체크박스가 변경될 때 호출되는 함수
  void onCheckboxChanged(bool? value, String code) {
    setState(() {
      if (value == true) {
        selectedCodes.add(code);
      } else {
        selectedCodes.remove(code);
      }
    });

    // 선택된 코드로 데이터 요청
    if (selectedCodes.isNotEmpty) {
      fetchData(selectedCodes.join(','));
    } else {
      setState(() {
        fetchedData.clear(); // 선택된 코드가 없으면 데이터 초기화
      });
    }
  }

  // 팝업 창 표시 함수
  void showCompanyInfoDialog(String companyName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(companyName), // 회사명 표시
          content: SingleChildScrollView(
            child: Text(companyInfo), // 불러온 회사 정보 표시
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('닫기'),
            ),
          ],
        );
      },
    );

    // 회사 정보 불러오기
    fetchCompanyInfo(companyName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 사이드바
          Container(
            width: 330,
            padding: const EdgeInsets.fromLTRB(16.0, 28.0, 16.0, 16.0),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"전국의 IT 기업을 알려드립니다"',  // 추가된 텍스트
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),  // 텍스트와 업종 섹션 간의 간격 추가
                // 업종 섹션 제목을 맨 위로 이동
                _buildSectionHeader('업종'),
                SizedBox(height: 10),
                _buildFilterSection(businessCodes),
              ],
            ),
          ),
          // 콘텐츠 영역
          Expanded(
            child: Container(
              color: Colors.white,
              child: Center(
                child: Container(
                  width: 1100,
                  height: 600,
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  color: Colors.grey[300],
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // 출력된 데이터와 함께 구분선 삽입
                        for (var item in fetchedData) ...[
                          GestureDetector(
                            onTap: () {
                              showCompanyInfoDialog(item); // 클릭 시 팝업 열기
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                item,
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                          Divider(), // 구분선 추가
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(Map<String, String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.entries.map((entry) {
        return Row(
          children: [
            Checkbox(
              value: selectedCodes.contains(entry.value),
              onChanged: (value) => onCheckboxChanged(value, entry.value),
            ),
            Flexible(
              child: Text(
                entry.key,
                softWrap: true,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      softWrap: true,
    );
  }
}
