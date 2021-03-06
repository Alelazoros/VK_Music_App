import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:vk_parse/functions/format/image.dart';
import 'package:vk_parse/provider/account_data.dart';
import 'package:vk_parse/provider/music_data.dart';
import 'package:vk_parse/provider/download_data.dart';
import 'package:vk_parse/ui/Account/friends.dart';
import 'package:vk_parse/ui/Account/auth_vk.dart';
import 'package:vk_parse/ui/Account/account_edit.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:vk_parse/ui/Account/search_music.dart';
import 'package:vk_parse/ui/Account/search_people.dart';

class AccountPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    AccountData accountData = Provider.of<AccountData>(context);
    MusicData musicData = Provider.of<MusicData>(context);
    MusicDownloadData downloadData = Provider.of<MusicDownloadData>(context);

    return CupertinoPageScaffold(
        key: _scaffoldKey,
        navigationBar: CupertinoNavigationBar(middle: Text('Profile')),
        child: _buildSelfShow(accountData, musicData, downloadData));
  }

  _buildSelfShow(AccountData accountData, MusicData musicData,
      MusicDownloadData downloadData) {
    return ListView(children: [
      Padding(
          padding: EdgeInsets.only(bottom: 15, top: 15),
          child: GestureDetector(
            onTap: () {
              showCupertinoModalPopup(
                  context: _scaffoldKey.currentContext,
                  builder: (context) {
                    return CupertinoActionSheet(
                      actions: <Widget>[
                        CupertinoActionSheetAction(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.of(_scaffoldKey.currentContext).push(
                                  CupertinoPageRoute(
                                      builder: (context) =>
                                          ChangeNotifierProvider<
                                                  AccountData>.value(
                                              value: accountData,
                                              child: AccountEditPage())));
                            },
                            child: Text('Edit')),
                        CupertinoActionSheetAction(
                            onPressed: () async {
                              await accountData.makeLogout();
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Logout',
                              style: TextStyle(color: Colors.red),
                            ))
                      ],
                    );
                  });
            },
            child: Center(
                child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.grey,
                    backgroundImage:
                        Image.network(formatImage(accountData.user.image))
                            .image)),
          )),
      Padding(
          padding: EdgeInsets.only(bottom: 25),
          child: Center(
              child: Text(
                  accountData.user.last_name.isEmpty &&
                          accountData.user.first_name.isEmpty
                      ? ''
                      : '${accountData.user.first_name} ${accountData.user.last_name}',
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)))),
      Divider(height: 1, color: Colors.grey),
      Material(
          color: Colors.transparent,
          child: ListTile(
            leading: Icon(SFSymbols.music_albums, color: Colors.white),
            onTap: () {
              Navigator.of(_scaffoldKey.currentContext).push(CupertinoPageRoute(
                  builder: (context) => MultiProvider(providers: [
                        ChangeNotifierProvider<MusicDownloadData>.value(
                            value: downloadData),
                      ], child: SearchMusicPage())));
            },
            title: Text(
              'Music Search',
              style: TextStyle(color: Colors.white),
            ),
          )),
      Divider(height: 1, color: Colors.grey),
      Material(
          color: Colors.transparent,
          child: ListTile(
            leading: Icon(SFSymbols.search, color: Colors.white),
            onTap: () {
              Navigator.of(_scaffoldKey.currentContext).push(CupertinoPageRoute(
                  builder: (context) => MultiProvider(providers: [
                        ChangeNotifierProvider<MusicDownloadData>.value(
                            value: downloadData),
                        ChangeNotifierProvider<AccountData>.value(
                            value: accountData),
                      ], child: SearchPeoplePage())));
            },
            title: Text(
              'People Search',
              style: TextStyle(color: Colors.white),
            ),
          )),
      Divider(height: 1, color: Colors.grey),
      Material(
          color: Colors.transparent,
          child: ListTile(
            leading: Icon(SFSymbols.person_2_alt, color: Colors.white),
            onTap: () {
              Navigator.of(_scaffoldKey.currentContext).push(CupertinoPageRoute(
                  builder: (context) => MultiProvider(providers: [
                        ChangeNotifierProvider<MusicDownloadData>.value(
                            value: downloadData),
                        ChangeNotifierProvider<AccountData>.value(
                            value: accountData),
                      ], child: FriendListPage())));
            },
            title: Text(
              'Friends',
              style: TextStyle(color: Colors.white),
            ),
          )),
      Divider(height: 1, color: Colors.grey),
      Material(
          color: Colors.transparent,
          child: ListTile(
            leading: Icon(SFSymbols.arrow_down_to_line, color: Colors.white),
            onTap: () => _downloadAll(accountData, musicData, downloadData),
            title: Text(
              'Download all',
              style: TextStyle(color: Colors.white),
            ),
          )),
      Divider(height: 1, color: Colors.grey),
    ]);
  }

  _downloadAll(AccountData accountData, MusicData musicData,
      MusicDownloadData downloadData) async {
    if (accountData.user.can_use_vk) {
      await musicData.loadSavedMusic();
      downloadData.multiQuery = musicData.localSongs;
    } else {
      showDialog(
          context: _scaffoldKey.currentContext,
          builder: (BuildContext context) => CupertinoAlertDialog(
                  title: Text('Error'),
                  content: Text(
                      'In order to download, you have to allow access to your account details'),
                  actions: [
                    CupertinoDialogAction(
                        isDefaultAction: true,
                        child: Text("Later"),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    CupertinoDialogAction(
                        isDefaultAction: true,
                        child: Text("Submit"),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(_scaffoldKey.currentContext).push(
                              CupertinoPageRoute(
                                  builder: (context) =>
                                      ChangeNotifierProvider<AccountData>.value(
                                          value: accountData,
                                          child: VKAuthPage(accountData))));
                        })
                  ]));
    }
  }
}
