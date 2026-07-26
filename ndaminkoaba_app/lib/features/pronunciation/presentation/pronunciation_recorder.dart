import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:record/record.dart';

import '../../../design_system/cards/featured_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/waveform_visualizer.dart';
import '../../badges/domain/badge_entry.dart';
import '../data/pronunciation_repository.dart';
import '../data/wav_encoder.dart';
import '../domain/pronunciation_attempt.dart';

const _kSampleRate = 16000;

/// Mic-recording pronunciation practice widget shared by the Lesson screen's
/// "Your Pronunciation" card and the Practice tab's pronunciation section:
/// records via [AudioRecorder.startStream] (raw PCM, works identically on
/// web and mobile — no platform-specific file/blob handling needed), wraps
/// the result as a WAV file client-side, and submits it for scoring.
class PronunciationRecorder extends StatefulWidget {
  const PronunciationRecorder({
    super.key,
    required this.targetText,
    this.vocabularyId,
    this.lessonId,
    this.onNewlyEarnedBadges,
    this.title = 'Your Pronunciation',
  });

  final String targetText;
  final String? vocabularyId;
  final String? lessonId;
  final void Function(List<BadgeEntry> badges)? onNewlyEarnedBadges;
  final String title;

  @override
  State<PronunciationRecorder> createState() => _PronunciationRecorderState();
}

class _PronunciationRecorderState extends State<PronunciationRecorder> {
  final _recorder = AudioRecorder();
  final _repository = PronunciationRepository();
  final _pcmBuffer = BytesBuilder();
  StreamSubscription<Uint8List>? _streamSubscription;

  bool _isRecording = false;
  bool _isSubmitting = false;
  String? _error;
  PronunciationAttempt? _result;

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      if (!mounted) return;
      setState(() => _error = 'Microphone permission is required to practice pronunciation.');
      return;
    }

    _pcmBuffer.clear();
    setState(() {
      _isRecording = true;
      _error = null;
      _result = null;
    });

    final stream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: _kSampleRate,
        numChannels: 1,
      ),
    );
    _streamSubscription = stream.listen((chunk) => _pcmBuffer.add(chunk));
  }

  Future<void> _stopAndSubmit() async {
    await _recorder.stop();
    await _streamSubscription?.cancel();
    _streamSubscription = null;

    if (!mounted) return;
    setState(() {
      _isRecording = false;
      _isSubmitting = true;
    });

    try {
      final wavBytes = wrapPcm16AsWav(
        _pcmBuffer.toBytes(),
        sampleRate: _kSampleRate,
        numChannels: 1,
      );

      final result = await _repository.submit(
        audioBytes: wavBytes,
        filename: 'attempt.wav',
        targetText: widget.targetText,
        vocabularyId: widget.vocabularyId,
        lessonId: widget.lessonId,
      );

      if (!mounted) return;
      setState(() {
        _result = result.attempt;
        _isSubmitting = false;
      });
      if (result.newlyEarnedBadges.isNotEmpty) {
        widget.onNewlyEarnedBadges?.call(result.newlyEarnedBadges);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _error = "Couldn't submit your recording — please try again.";
      });
    }
  }

  Color _scoreColor(int score) {
    if (score >= 70) return AppColors.success;
    if (score >= 40) return AppColors.warning;
    return AppColors.error;
  }

  String get _statusText {
    if (_isRecording) return 'Recording…';
    if (_isSubmitting) return 'Scoring…';
    if (_result != null) return _result!.scored ? 'Scored' : 'Not scored';
    return 'Ready to record';
  }

  @override
  Widget build(BuildContext context) {
    return FeaturedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: AppTypography.title.copyWith(fontSize: 15)),
          const SizedBox(height: AppSpacing.md),
          WaveformVisualizer(animate: _isRecording, height: 32),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(_statusText, style: AppTypography.caption),
              ),
              OutlinedButton.icon(
                onPressed: _isSubmitting ? null : (_isRecording ? _stopAndSubmit : _startRecording),
                icon: _isSubmitting
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(_isRecording ? Icons.stop : Icons.mic, size: 16),
                label: Text(
                  _isRecording ? 'STOP RECORDING' : 'START RECORDING',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.circle),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(_error!, style: AppTypography.caption.copyWith(color: AppColors.error)),
          ],
          if (_result != null) ...[
            const SizedBox(height: AppSpacing.lg),
            if (_result!.scored) ...[
              Row(
                children: [
                  Text(
                    '${_result!.accuracyScore}%',
                    style: AppTypography.numeric.copyWith(color: _scoreColor(_result!.accuracyScore ?? 0)),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(_result!.feedback ?? '', style: AppTypography.caption),
                  ),
                ],
              ),
            ] else
              Text(
                _result!.feedback ?? "Couldn't score that attempt.",
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              ),
          ],
        ],
      ),
    );
  }
}
