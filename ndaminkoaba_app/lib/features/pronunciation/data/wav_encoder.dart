import 'dart:typed_data';

/// Wraps raw PCM16 mono samples (as streamed by `record`'s
/// `AudioEncoder.pcm16bits`) in a standard 44-byte WAV/RIFF header, so the
/// result is a normal playable/uploadable .wav file. Pure byte manipulation
/// — no platform channel or file-system access needed, which is what makes
/// this work identically on web and mobile without conditional imports.
Uint8List wrapPcm16AsWav(Uint8List pcmData, {required int sampleRate, required int numChannels}) {
  const bitsPerSample = 16;
  final byteRate = sampleRate * numChannels * bitsPerSample ~/ 8;
  final blockAlign = numChannels * bitsPerSample ~/ 8;
  final dataLength = pcmData.length;

  final header = BytesBuilder();
  void writeString(String s) => header.add(s.codeUnits);
  void writeUint32(int v) => header.add([
        v & 0xff,
        (v >> 8) & 0xff,
        (v >> 16) & 0xff,
        (v >> 24) & 0xff,
      ]);
  void writeUint16(int v) => header.add([v & 0xff, (v >> 8) & 0xff]);

  writeString('RIFF');
  writeUint32(36 + dataLength);
  writeString('WAVE');
  writeString('fmt ');
  writeUint32(16); // fmt chunk size
  writeUint16(1); // PCM format
  writeUint16(numChannels);
  writeUint32(sampleRate);
  writeUint32(byteRate);
  writeUint16(blockAlign);
  writeUint16(bitsPerSample);
  writeString('data');
  writeUint32(dataLength);

  final result = BytesBuilder();
  result.add(header.toBytes());
  result.add(pcmData);
  return result.toBytes();
}
