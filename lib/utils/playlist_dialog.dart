import 'package:flutter/material.dart';
import 'package:vk_parse/models/playlist.dart';

class DialogPlaylistContent extends StatefulWidget {
  final List<PlaylistCheckbox> playlistList;

  DialogPlaylistContent({Key key, this.playlistList}) : super(key: key);

  @override
  DialogPlaylistContentState createState() => new DialogPlaylistContentState();
}

class DialogPlaylistContentState extends State<DialogPlaylistContent> {
  @override
  Widget build(BuildContext context) {
    return widget.playlistList.length == 0
        ? Container()
        : Column(
            children: List<Column>.generate(widget.playlistList.length,
                (int index) => _buildPlaylistList(index)));
  }

  _buildPlaylistList(int index) {
    PlaylistCheckbox playlist = widget.playlistList[index];
    return Column(children: [
      CheckboxListTile(
        checkColor: Colors.white,
        activeColor: Colors.redAccent,
        title: Text(
          playlist.playlist.title,
          style: TextStyle(color: Colors.white),
        ),
        value: playlist.checked,
        onChanged: (value) {
          setState(() {
            playlist.checked = !playlist.checked;
          });
        },
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Divider(color: Colors.grey),
      )
    ]);
  }
}
