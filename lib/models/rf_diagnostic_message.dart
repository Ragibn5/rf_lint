import 'package:analyzer/diagnostic/diagnostic.dart';

class RfDiagnosticMessage extends DiagnosticMessage {
  final int mOffset;
  final int mLength;

  final String mFilePath;
  final String mMessage;

  final String? mUrl;

  RfDiagnosticMessage({
    required this.mOffset,
    required this.mLength,
    required this.mFilePath,
    required this.mMessage,
    this.mUrl,
  });

  @override
  String get filePath => mFilePath;

  @override
  int get length => mLength;

  @override
  String messageText({required bool includeUrl}) {
    return mMessage;
  }

  @override
  int get offset => mOffset;

  @override
  String? get url => null;
}
