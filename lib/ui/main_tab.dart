import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vk_parse/provider/account_data.dart';
import 'package:vk_parse/provider/download_data.dart';
import 'package:vk_parse/ui/Account/login.dart';
import 'package:vk_parse/ui/Music/player.dart';
import 'package:vk_parse/ui/Music/playylist.dart';
import 'package:provider/provider.dart';
import 'package:vk_parse/provider/music_data.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:vk_parse/ui/Music/music_list.dart';
import 'package:vk_parse/ui/Account/account.dart';
import 'package:vk_parse/ui/Music/vk_music.dart';
import 'package:vk_parse/utils/swipe_detector.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new MainPageState();
}

class MainPageState extends State<MainPage> {
  int currentIndex = 0;

  Widget _buildView(MusicData musicData, AccountData accountData,
      MusicDownloadData downloadData, Widget child) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<MusicData>.value(value: musicData),
      ChangeNotifierProvider<MusicDownloadData>.value(value: downloadData),
      ChangeNotifierProvider<AccountData>.value(value: accountData),
    ], child: child);
  }

  Widget _switchTabs(MusicData musicData, MusicDownloadData downloadData,
      AccountData accountData, int index) {
    Widget page;

    switch (index) {
      case 0:
        page = ChangeNotifierProvider<MusicData>.value(
            value: musicData,
            child: CupertinoTabView(
                builder: (BuildContext context) => PlaylistPage()));
        break;
      case 1:
        page = CupertinoTabView(
            builder: (BuildContext context) =>
                ChangeNotifierProvider<MusicData>.value(
                    value: musicData, child: MusicListPage()));
        break;
      case 2:
        page = CupertinoTabView(
            builder: (BuildContext context) => _buildView(
                musicData, accountData, downloadData, VKMusicListPage()));
        break;
      case 3:
        page = CupertinoTabView(
            builder: (BuildContext context) => _buildView(
                musicData,
                accountData,
                downloadData,
                accountData.user != null ? AccountPage() : LoginPage()));
        break;
    }
    return Stack(
      children: <Widget>[page, _buildPlayer(musicData)],
    );
  }

  void _openPlayer(MusicData musicData) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          ChangeNotifierProvider<MusicData>.value(
              value: musicData, child: PlayerPage()),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: animation.drive(
              Tween(begin: Offset(0.0, 1.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.ease))),
          child: child,
        );
      },
    ));
  }

  Widget _buildPlayer(MusicData musicData) {
    return musicData.currentSong != null
        ? Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
                child: SwipeDetector(
                    onTap: () => _openPlayer(musicData),
                    onSwipeUp: () => _openPlayer(musicData),
                    onSwipeDown: () {
                      musicData.playerStop();
                      setState(() {
                        musicData.currentSong = null;
                      });
                    },
                    child: ClipRect(
                        child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                            child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.black26.withOpacity(0.3)),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                alignment: Alignment.bottomCenter,
                                child: Row(
                                  children: <Widget>[
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.grey,
                                    ),
                                    Container(width: 25),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          musicData.currentSong.title,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Divider(
                                          height: 5,
                                        ),
                                        Text(
                                          musicData.currentSong.artist,
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 15),
                                        ),
                                      ],
                                    ),
                                    Expanded(child: SizedBox()),
                                    GestureDetector(
                                      child: Icon(
                                        musicData.playerState ==
                                                AudioPlayerState.PLAYING
                                            ? SFSymbols.pause_fill
                                            : SFSymbols.play_fill,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onTap: () => musicData.playerState ==
                                              AudioPlayerState.PLAYING
                                          ? musicData.playerPause()
                                          : musicData.playerResume(),
                                    ),
                                    SizedBox(width: 10),
                                    GestureDetector(
                                      child: Icon(
                                        SFSymbols.forward_fill,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      onTap: () => musicData.next(),
                                    )
                                  ],
                                )))))))
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    MusicData musicData = Provider.of<MusicData>(context);
    MusicDownloadData downloadData = Provider.of<MusicDownloadData>(context);
    AccountData accountData = Provider.of<AccountData>(context);

    return WillPopScope(
        onWillPop: () => Future<bool>.value(true),
        child: CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
              activeColor: Colors.redAccent,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(SFSymbols.music_note_list),
                    title: Text('Playlist')),
                BottomNavigationBarItem(
                    icon: Icon(SFSymbols.folder), title: Text('Media')),
                BottomNavigationBarItem(
                    icon: Icon(SFSymbols.music_note_2), title: Text('Music')),
                BottomNavigationBarItem(
                    icon: Icon(SFSymbols.person_alt), title: Text('Account'))
              ],
            ),
            tabBuilder: (BuildContext context, int index) {
              return _switchTabs(musicData, downloadData, accountData, index);
            }));
  }
}
