import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:vk_parse/api/musicList.dart';
import 'package:vk_parse/functions/format/formatImage.dart';
import 'package:vk_parse/functions/format/formatTime.dart';
import 'package:vk_parse/functions/utils/downloadSong.dart';
import 'package:vk_parse/models/Relationship.dart';
import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/provider/AccountData.dart';
import 'package:vk_parse/utils/urls.dart';

class PeoplePage extends StatefulWidget {
  final Relationship relationship;

  PeoplePage(this.relationship);

  @override
  State<StatefulWidget> createState() => new PeoplePageState();
}

class PeoplePageState extends State<PeoplePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Song> _friendSongList = [];

  @override
  Widget build(BuildContext context) {
    AccountData accountData = Provider.of<AccountData>(context);

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(widget.relationship.user.username),
          centerTitle: true,
          actions: widget.relationship.status != RelationshipStatus.BLOCK
              ? <Widget>[
                  IconButton(
                    icon: Icon(Icons.block),
                    onPressed: () {},
                  )
                ]
              : [],
        ),
        body: widget.relationship.status != RelationshipStatus.BLOCK
            ? _buildPage(accountData)
            : Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Container(
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Icons.block,
                                color: Colors.grey,
                                size:
                                    MediaQuery.of(context).size.height * 0.35),
                            Text(
                              'User has blocked you',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 25),
                              textAlign: TextAlign.center,
                            )
                          ])),
                )));
  }

  _buildPage(AccountData accountData) {
    return Container(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
                padding: EdgeInsets.only(bottom: 15, top: 15),
                child: CircleAvatar(
                    radius: MediaQuery.of(context).size.height * 0.13,
                    backgroundColor: Colors.grey,
                    backgroundImage: Image.network(
                            formatImage(widget.relationship.user.image))
                        .image)),
            Text(
                widget.relationship.user.last_name.isEmpty &&
                        widget.relationship.user.first_name.isEmpty
                    ? 'Unknown'
                    : '${widget.relationship.user.first_name} ${widget.relationship.user.last_name}',
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.035,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Padding(
                padding: EdgeInsets.only(bottom: 15, top: 15),
                child: CupertinoButton(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  color: widget.relationship.status == RelationshipStatus.FRIEND
                      ? Colors.redAccent
                      : Colors.indigo,
                  onPressed: () {},
                  child: Text(widget.relationship.buttonName()),
                )),
            Divider(),
            Flexible(
                child: widget.relationship.status == RelationshipStatus.FRIEND
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: _friendSongList.length,
                        itemBuilder: (context, index) => _buildSong(index),
                      )
                    : Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Only friends can view the list of tracks',
                          style: TextStyle(color: Colors.grey, fontSize: 20),
                          textAlign: TextAlign.center,
                        )))
          ],
        ));
  }

  _buildSong(int index) {
    Song song = _friendSongList[index];
    if (song == null) {
      return null;
    }
    return Column(children: [
      Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: new Container(
            child: ListTile(
          contentPadding: EdgeInsets.only(left: 30, right: 20),
          title: Text(song.title,
              style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
          subtitle: Text(song.artist,
              style: TextStyle(color: Color.fromRGBO(150, 150, 150, 1))),
          onTap: () {
//            saveSong(song, context); TODO
          },
          trailing: Text(formatDuration(song.duration),
              style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
        )),
        actions: !song.in_my_list
            ? <Widget>[
                new IconSlideAction(
                    caption: 'Add',
                    color: Colors.blue,
                    icon: Icons.add,
                    onTap: () async {
                      bool isAdded = await addMusic(song.song_id);
                      if (isAdded) {
                        setState(() {
                          song.in_my_list = true;
                        });
                      }
                    }),
              ]
            : [],
        secondaryActions: song.in_my_list
            ? <Widget>[
                new IconSlideAction(
                  caption: 'Delete',
                  color: Colors.red,
                  icon: Icons.delete,
                  onTap: () async {
                    bool isDeleted = await hideMusic(song.song_id);
                    if (isDeleted) {
                      setState(() {
                        song.in_my_list = false;
                      });
                    }
                  },
                ),
              ]
            : [],
      ),
      Padding(padding: EdgeInsets.only(left: 12.0), child: Divider(height: 1))
    ]);
  }
}