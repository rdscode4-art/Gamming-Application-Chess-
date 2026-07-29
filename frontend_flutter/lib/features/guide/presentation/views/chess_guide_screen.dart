import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bg_blobs.dart';
import '../../../../core/widgets/glass_card.dart';

class ChessGuideScreen extends StatefulWidget {
  const ChessGuideScreen({super.key});

  @override
  State<ChessGuideScreen> createState() => _ChessGuideScreenState();
}

class _ChessGuideScreenState extends State<ChessGuideScreen> {
  List<dynamic> _guides = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchGuides();
  }

  Future<void> _fetchGuides() async {
    try {
      final response = await http.get(Uri.parse('https://chessback.ridealdigitalseva.com/api/guides'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _guides = data['data'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = 'Failed to load guides';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Server error';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error. Please try again later.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.navyGrad
                  : const LinearGradient(
                      colors: [Colors.white, Color(0xFFF5F5F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
            ),
          ),
          if (Theme.of(context).brightness == Brightness.dark) const BgBlobs(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                      : _error.isNotEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(_error, style: const TextStyle(color: Colors.red)),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _isLoading = true;
                                        _error = '';
                                      });
                                      _fetchGuides();
                                    },
                                    child: const Text('Retry'),
                                  )
                                ],
                              ),
                            )
                          : _guides.isEmpty
                              ? const Center(child: Text('No guides available yet.', style: TextStyle(color: Colors.grey)))
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                  itemCount: _guides.length,
                                  itemBuilder: (context, index) {
                                    final guide = _guides[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 24),
                                      child: _buildDynamicGuideSection(context, guide),
                                    );
                                  },
                                ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, size: 20),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
          Text(
            'Chess Guide',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Rajdhani',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicGuideSection(BuildContext context, Map<String, dynamic> guide) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.menu_book_rounded, color: AppColors.gold, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  guide['title'] ?? 'Section',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Rajdhani',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            guide['content'] ?? '',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
              fontSize: 15,
              height: 1.6,
            ),
          ),
          if (guide['mediaType'] != null && guide['mediaType'] != 'none' && guide['mediaUrl'] != null && guide['mediaUrl'] != '')
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildMedia(guide['mediaType'], guide['mediaUrl']),
              ),
            ),
        ],
      ),
    );
  }

  String? _extractYoutubeId(String url) {
    RegExp regExp = RegExp(
      r'.*(?:youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*',
      caseSensitive: false,
      multiLine: false,
    );
    Match? match = regExp.firstMatch(url);
    if (match != null && match.group(1)?.length == 11) {
      return match.group(1);
    }
    return null;
  }

  Widget _buildMedia(String type, String url) {
    String fullUrl = url;
    if (url.startsWith('/')) {
      fullUrl = 'https://chessback.ridealdigitalseva.com$url';
    }

    if (type == 'image') {
      return CachedNetworkImage(
        imageUrl: fullUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 200,
          color: Colors.black12,
          child: const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        ),
        errorWidget: (context, url, error) => Container(
          height: 150,
          color: Colors.black12,
          child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
        ),
      );
    } else if (type == 'youtube') {
      final videoId = _extractYoutubeId(fullUrl);
      if (videoId != null) {
        final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/0.jpg';
        return GestureDetector(
          onTap: () async {
            final uri = Uri.parse(fullUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: thumbnailUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: Colors.black12,
                  child: const Center(child: CircularProgressIndicator(color: AppColors.gold)),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: Colors.black12,
                  child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
              ),
            ],
          ),
        );
      }
      return const Text("Invalid YouTube URL");
    } else if (type == 'video') {
      return _LocalVideoPlayerWidget(url: fullUrl);
    }
    
    return const SizedBox.shrink();
  }
}

// ---------------------------------------------------------
// Helper Widget for Local Video (MP4)
// ---------------------------------------------------------
class _LocalVideoPlayerWidget extends StatefulWidget {
  final String url;
  const _LocalVideoPlayerWidget({required this.url});

  @override
  State<_LocalVideoPlayerWidget> createState() => _LocalVideoPlayerWidgetState();
}

class _LocalVideoPlayerWidgetState extends State<_LocalVideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
      }).catchError((e) {
        debugPrint("Video Player error: $e");
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Container(
        height: 200,
        color: Colors.black12,
        child: const Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }
    
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(_controller),
          _ControlsOverlay(controller: _controller),
          VideoProgressIndicator(_controller, allowScrubbing: true, colors: const VideoProgressColors(playedColor: AppColors.gold)),
        ],
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, VideoPlayerValue value, child) {
        return Stack(
          children: <Widget>[
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 50),
              reverseDuration: const Duration(milliseconds: 200),
              child: value.isPlaying
                  ? const SizedBox.shrink()
                  : Container(
                      color: Colors.black26,
                      child: const Center(
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 60.0,
                        ),
                      ),
                    ),
            ),
            GestureDetector(
              onTap: () {
                value.isPlaying ? controller.pause() : controller.play();
              },
            ),
          ],
        );
      },
    );
  }
}
