import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';

import '../../../../config/app_config.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';
import '../../../pronunciation/data/wav_encoder.dart';
import '../../data/knowledge_repository.dart';

const _kSampleRate = 16000;

// ~0.25s of 16kHz mono 16-bit PCM (16000 * 2 bytes/sample * 0.25s). Below
// this, treat the capture as an empty/near-empty recording rather than
// uploading a WAV that's effectively just its own header.
const _kMinPcmBytes = 8000;

/// Lets an admin attach a reference pronunciation recording to a Vocabulary
/// entry, either by recording live through the mic or picking an audio file
/// — combines the record-then-WAV-wrap flow used by the learner-facing
/// [PronunciationRecorder] with the file-picker flow used by the Lesson
/// Editor's AUDIO block.
///
/// This only sets `Vocabulary.audioUrl`, which powers "hear it said
/// correctly" playback for learners. Pronunciation-attempt scoring compares
/// a transcript of the learner's own recording against the word's text, not
/// against this reference audio, so this field doesn't change scoring — it
/// makes correct-pronunciation playback possible at all, which today's Add/
/// Edit Knowledge form has no way to set.
class AudioRecorderField extends StatefulWidget {
  const AudioRecorderField({
    super.key,
    required this.initialUrl,
    required this.onChanged,
    this.label = 'Pronunciation audio',
  });

  final String? initialUrl;
  final ValueChanged<String?> onChanged;
  final String label;

  @override
  State<AudioRecorderField> createState() => _AudioRecorderFieldState();
}

class _AudioRecorderFieldState extends State<AudioRecorderField> {
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();
  final _repository = KnowledgeRepository();
  final _pcmBuffer = BytesBuilder();
  StreamSubscription<Uint8List>? _streamSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  late String? audioUrl = widget.initialUrl;
  bool isRecording = false;
  bool isUploading = false;
  bool isPlaying = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _playerStateSubscription = _player.playerStateStream.listen((state) {
      if (!mounted) return;
      if (state.processingState == ProcessingState.completed) {
        setState(() => isPlaying = false);
      }
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  void _setAudioUrl(String? url) {
    setState(() => audioUrl = url);
    widget.onChanged(url);
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      if (!mounted) return;
      setState(() => error = 'Microphone permission is required to record.');
      return;
    }
    _pcmBuffer.clear();
    setState(() {
      isRecording = true;
      error = null;
    });
    final stream = await _recorder.startStream(
      const RecordConfig(encoder: AudioEncoder.pcm16bits, sampleRate: _kSampleRate, numChannels: 1),
    );
    _streamSubscription = stream.listen((chunk) => _pcmBuffer.add(chunk));
  }

  Future<void> _stopAndUpload() async {
    await _recorder.stop();
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    if (!mounted) return;

    // Stopping near-instantly after starting (mic init latency, an
    // accidental double-tap) can leave the buffer empty or almost empty,
    // producing a WAV that's just a 44-byte header with no audio. Refuse to
    // upload that rather than silently attaching a broken "recording".
    final pcmBytes = _pcmBuffer.toBytes();
    if (pcmBytes.length < _kMinPcmBytes) {
      setState(() {
        isRecording = false;
        error = 'Recording was too short — hold Record for at least a second and try again.';
      });
      return;
    }

    setState(() {
      isRecording = false;
      isUploading = true;
    });
    try {
      final wavBytes = wrapPcm16AsWav(pcmBytes, sampleRate: _kSampleRate, numChannels: 1);
      final url = await _repository.uploadAudio(wavBytes, 'pronunciation.wav');
      if (!mounted) return;
      _setAudioUrl(url);
    } catch (_) {
      if (!mounted) return;
      setState(() => error = "Couldn't upload the recording — please try again.");
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'ogg'],
      withData: true,
    );
    if (result == null || result.files.isEmpty || result.files.first.bytes == null) return;
    final picked = result.files.first;
    setState(() {
      isUploading = true;
      error = null;
    });
    try {
      final url = await _repository.uploadAudio(picked.bytes!, picked.name);
      if (!mounted) return;
      _setAudioUrl(url);
    } catch (_) {
      if (!mounted) return;
      setState(() => error = "Couldn't upload the file — please try again.");
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  Future<void> _togglePlayback() async {
    if (audioUrl == null) return;
    if (isPlaying) {
      await _player.pause();
      if (mounted) setState(() => isPlaying = false);
      return;
    }
    try {
      await _player.setUrl(AppConfig.resolveUrl(audioUrl!));
      await _player.play();
      if (mounted) setState(() => isPlaying = true);
    } catch (_) {
      if (mounted) setState(() => error = "Couldn't play that audio.");
    }
  }

  void _remove() => _setAudioUrl(null);

  @override
  Widget build(BuildContext context) {
    final busy = isRecording || isUploading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              if (audioUrl != null && !busy)
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle, color: AppColors.ai),
                  onPressed: _togglePlayback,
                  tooltip: isPlaying ? 'Pause' : 'Play',
                ),
              Expanded(
                child: Text(
                  isRecording
                      ? 'Recording…'
                      : isUploading
                          ? 'Uploading…'
                          : audioUrl != null
                              ? 'Recording attached'
                              : 'No audio yet',
                  style: AppTypography.caption.copyWith(
                    color: audioUrl != null && !busy ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
              ),
              if (isUploading)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else ...[
                if (audioUrl != null && !isRecording)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    tooltip: 'Remove',
                    onPressed: _remove,
                  ),
                IconButton(
                  icon: Icon(
                    isRecording ? Icons.stop_circle : Icons.mic,
                    color: isRecording ? AppColors.error : AppColors.textSecondary,
                  ),
                  tooltip: isRecording ? 'Stop recording' : 'Record',
                  onPressed: isRecording ? _stopAndUpload : _startRecording,
                ),
                IconButton(
                  icon: const Icon(Icons.upload_file, color: AppColors.textSecondary),
                  tooltip: 'Upload file',
                  onPressed: isRecording ? null : _pickFile,
                ),
              ],
            ],
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(error!, style: AppTypography.caption.copyWith(color: AppColors.error)),
        ],
      ],
    );
  }
}
