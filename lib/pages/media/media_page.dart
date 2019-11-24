import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MediaPage extends StatefulWidget {
  const MediaPage({Key key}) : super(key: key);

  @override
  _MediaPageState createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  YoutubePlayerController _controller = YoutubePlayerController(
    initialVideoId: 'liEGSeD3Zt8',
    flags: YoutubePlayerFlags(
      autoPlay: true,
      mute: true,
    ),
  );

  Widget _buildPlayer() {
    return YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Media page"),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: _buildPlayer(),
          ),
        ),
      ),
    );
  }
}
