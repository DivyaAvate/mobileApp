import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/exercise_model.dart';

class ExerciseDetailPage extends StatefulWidget {
  // Accept either full model or just an ID (from router)
  final ExerciseModel? exercise;
  final String         exerciseId;

  const ExerciseDetailPage({
    super.key,
    this.exercise,
    this.exerciseId = '',
  });

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() {
    final videoUrl = widget.exercise?.videoUrl;
    if (videoUrl == null || videoUrl.isEmpty) return;

    final videoId = YoutubePlayer.convertUrlToId(videoUrl);
    if (videoId == null) return;

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute:     false,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;

    // If no exercise passed, show loading/error
    if (ex == null) {
      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        appBar: AppBar(backgroundColor: AppColors.bgPrimary),
        body: const Center(
          child: Text('Exercise not found',
            style: TextStyle(color: AppColors.textMuted))),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(ex.name,
          style: const TextStyle(
            color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Video / Thumbnail ──────────────────────────
            _controller != null
                ? YoutubePlayer(
                    controller: _controller!,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: AppColors.accentGreen,
                  )
                : Container(
                    height: 220,
                    width: double.infinity,
                    color: AppColors.bgCard,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_circle_outline,
                          color: AppColors.textMuted, size: 52),
                        const SizedBox(height: 8),
                        const Text('No video available',
                          style: TextStyle(color: AppColors.textMuted)),
                      ],
                    ),
                  ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Muscle tag ─────────────────────────────
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.accentGreen.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        ex.muscleGroup.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.accentGreen,
                          fontSize: 11, fontWeight: FontWeight.w600,
                          letterSpacing: 0.5)),
                    ),
                    if (ex.equipment.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.accentBlue.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          ex.equipment.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.accentBlue,
                            fontSize: 11, fontWeight: FontWeight.w600,
                            letterSpacing: 0.5)),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 20),

                  // ── Instructions ───────────────────────────
                  const Text('Instructions',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    ex.description.isNotEmpty
                        ? ex.description
                        : 'No instructions available.',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14, height: 1.6)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}