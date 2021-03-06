import 'dart:async';

import 'package:http/http.dart' as http;

import 'package:vk_parse/utils/urls.dart';
import 'package:vk_parse/functions/format/token.dart';
import 'package:vk_parse/functions/get/token.dart';

authCheckGet() async {
  try {
    final token = await getToken();
    final response = await http.get(AUTH_CHECK, headers: formatToken(token)).timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  } on TimeoutException catch(e) {
    return false;
  }
  catch (e) {
    print(e);
    return false;
  }
}
