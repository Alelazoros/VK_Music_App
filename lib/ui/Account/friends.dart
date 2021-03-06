import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import 'package:vk_parse/functions/format/image.dart';
import 'package:vk_parse/models/relationship.dart';
import 'package:vk_parse/provider/account_data.dart';
import 'package:vk_parse/provider/download_data.dart';
import 'package:vk_parse/ui/Account/people.dart';
import 'package:vk_parse/utils/apple_search.dart';

class FriendListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => FriendListPageState();
}

class FriendListPageState extends State<FriendListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();
  List<Relationship> friendListSorted = [];

  @override
  Widget build(BuildContext context) {
    AccountData accountData = Provider.of<AccountData>(context);
    MusicDownloadData downloadData = Provider.of<MusicDownloadData>(context);
    friendListSorted = accountData.friendList;

    return CupertinoPageScaffold(
      key: _scaffoldKey,
      navigationBar: CupertinoNavigationBar(
        middle: Text('Friends'),
        actionsForegroundColor: Colors.redAccent,
        previousPageTitle: 'Back',
      ),
      child: RefreshIndicator(
          key: _refreshKey,
          onRefresh: () => accountData.loadFiendList(),
          child: friendListSorted.length > 0
              ? ListView.builder(
                  itemCount: friendListSorted.length + 1,
                  itemBuilder: (context, index) =>
                      _buildUserCard(accountData, downloadData, index),
                )
              : ListView(children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: Text(
                        'Your friends list is empty',
                        style: TextStyle(color: Colors.grey, fontSize: 20),
                        textAlign: TextAlign.center,
                      ))
                ])),
    );
  }

  void _filterFriends(AccountData accountData, String value) {
    String newValue = value.toLowerCase();
    setState(() {
      friendListSorted = accountData.friendList
          .where((Relationship relationship) =>
              relationship.user.first_name.toLowerCase().contains(newValue) ||
              relationship.user.last_name.toLowerCase().contains(newValue))
          .toList();
    });
  }

  _buildUserCard(
      AccountData accountData, MusicDownloadData downloadData, int index) {
    if (index == 0) {
      return AppleSearch(onChange: (value) {
        _filterFriends(accountData, value);
      });
    }
    Relationship relationship = accountData.friendList[index - 1];

    return Column(children: [
      Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: Container(
            child: ListTile(
                title: Text(
                    relationship.user.last_name.isEmpty
                        ? 'Unknown'
                        : relationship.user.last_name,
                    style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
                subtitle: Text(
                    relationship.user.first_name.isEmpty
                        ? 'Unknown'
                        : relationship.user.first_name,
                    style: TextStyle(color: Color.fromRGBO(150, 150, 150, 1))),
                onTap: () {
                  Navigator.of(_scaffoldKey.currentContext)
                      .push(CupertinoPageRoute(
                          builder: (context) => MultiProvider(providers: [
                                ChangeNotifierProvider<MusicDownloadData>.value(
                                    value: downloadData),
                                ChangeNotifierProvider<AccountData>.value(
                                    value: accountData),
                              ], child: PeoplePage(relationship))));
                },
                leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey,
                    backgroundImage:
                        Image.network(formatImage(relationship.user.image))
                            .image))),
        secondaryActions: <Widget>[
          SlideAction(
            color: Colors.indigo,
            child: Icon(Icons.block, color: Colors.white),
            onTap: null,
          ),
          SlideAction(
            color: Colors.red,
            child: Icon(SFSymbols.trash, color: Colors.white),
            onTap: null,
          ),
        ],
      ),
      Padding(padding: EdgeInsets.only(left: 12.0), child: Divider(height: 1))
    ]);
  }
}
