import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pihu_fashion/models/channel_model.dart';
import 'package:pihu_fashion/models/video_model.dart';
import 'package:pihu_fashion/services/api_service.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoScreen extends StatefulWidget {
  final String id;

  VideoScreen({this.id});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  YoutubePlayerController _controller;
  Channel _channel;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initChannel();
    _controller = YoutubePlayerController(
      initialVideoId: widget.id,
      flags: YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
      ),
    );
  }

  _initChannel() async {
    Channel channel = await APIService.instance
        .fetchChannel(channelId: 'UCh95wTVDG-VAaEN10VjgxmQ');
    setState(() {
      _channel = channel;
    });
  }

  _buildProfileInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                  color: MaterialColor(0xffe32249, color),
                  borderRadius: new BorderRadius.only(
                      bottomRight: const Radius.circular(20.0),
                      topRight: const Radius.circular(20.0))),
              child: Padding(
                padding: EdgeInsets.all(10.0),


                    child: Text('Similar Designs',
                        style: GoogleFonts.lobster(
                          textStyle:
                          TextStyle(
                              color: Colors.white,
                              fontSize: 20.0, ),
                        ))

              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildVideo(Video video) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoScreen(id: video.id),
        ),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
//        padding: EdgeInsets.all(5.0),
        height: 140.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
//          color: MaterialColor(0xff27496d,color),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 1),
              blurRadius: 6.0,
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0)),
              child: Image(
                width: 150.0,
                image: NetworkImage(video.thumbnailUrl),
              ),
            ),
            SizedBox(width: 10.0),
            Expanded(
              child: Text(
                video.title,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _loadMoreVideos() async {
    _isLoading = true;
    List<Video> moreVideos = await APIService.instance
        .fetchVideosFromPlaylist(playlistId: _channel.uploadPlaylistId);
    List<Video> allVideos = _channel.videos..addAll(moreVideos);
    setState(() {
      _channel.videos = allVideos;
    });
    _isLoading = false;
  }

  static Map<int, Color> color = {
    50: Color.fromRGBO(136, 14, 79, .1),
    100: Color.fromRGBO(136, 14, 79, .2),
    200: Color.fromRGBO(136, 14, 79, .3),
    300: Color.fromRGBO(136, 14, 79, .4),
    400: Color.fromRGBO(136, 14, 79, .5),
    500: Color.fromRGBO(136, 14, 79, .6),
    600: Color.fromRGBO(136, 14, 79, .7),
    700: Color.fromRGBO(136, 14, 79, .8),
    800: Color.fromRGBO(136, 14, 79, .9),
    900: Color.fromRGBO(136, 14, 79, 1),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MaterialColor(0xffe32249, color),
      ),
      body: Column(
        children: <Widget>[
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            onReady: () {
              print('Player is ready.');
            },
          ),
          Expanded(
            child: Container(
              child: _channel != null
                  ? NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollDetails) {
                        if (!_isLoading &&
                            _channel.videos.length !=
                                int.parse(_channel.videoCount) &&
                            scrollDetails.metrics.pixels ==
                                scrollDetails.metrics.maxScrollExtent) {
//                          _loadMoreVideos();
                        }
                        return false;
                      },
                      child: ListView.builder(
                        itemCount: 1 + _channel.videos.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (index == 0) {
                            return _buildProfileInfo();
                          }
                          Video video = _channel.videos[index - 1];
                          return _buildVideo(video);
                        },
                      ),
                    )
                  : Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor, // Red
                        ),
                      ),
                    ),
            ),
          )
        ],
      ),
    );
  }
}
