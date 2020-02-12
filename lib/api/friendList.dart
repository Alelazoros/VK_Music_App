import 'package:http/http.dart' as http;
import 'package:vk_parse/models/Relationship.dart';
import 'dart:convert';

import 'package:vk_parse/utils/urls.dart';
import 'package:vk_parse/models/User.dart';
import 'package:vk_parse/functions/format/headersToken.dart';
import 'package:vk_parse/functions/get/getToken.dart';

friendListGet() async {
  try {
    final token = await getToken();
    final response =
        await http.get(FRIEND_LIST_URL, headers: formatToken(token));

    if (response.statusCode == 200) {
      var friendData =
          (json.decode(response.body) as Map) as Map<String, dynamic>;

      List<Relationship> friendList = [];
      friendData['result'].forEach((value) async {
        var friend = new User.fromJson(value['to_user']);
        friendList.add(Relationship(friend, statusId: value['status']));
      });
      return friendList;
    }
  } catch (e) {
    print(e);
  }
}
