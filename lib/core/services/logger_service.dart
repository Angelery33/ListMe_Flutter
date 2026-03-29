import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

enum LogLevel { debug, info, warning, error }

class LogEntry {
  final LogLevel level;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  LogEntry({
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

abstract class LogSink {
  void write(LogEntry entry);
  bool shouldLog(LogLevel level);
}

class ConsoleSink implements LogSink {
  final LogLevel minimumLevel;

  ConsoleSink({this.minimumLevel = LogLevel.debug});

  @override
  bool shouldLog(LogLevel level) => level.index >= minimumLevel.index;

  @override
  void write(LogEntry entry) {
    final timestamp = DateFormat(
      'yyyy-MM-dd HH:mm:ss.SSS',
    ).format(entry.timestamp);
    final levelStr = entry.level.name.toUpperCase().padRight(7);
    final colorCode = _getColorCode(entry.level);

    final buffer = StringBuffer();
    buffer.write('$colorCode[$timestamp] $levelStr: ${entry.message}');

    if (entry.error != null) {
      buffer.write('\nError: ${entry.error}');
    }
    if (entry.stackTrace != null) {
      buffer.write('\nStackTrace: ${entry.stackTrace}');
    }

    debugPrint(buffer.toString());
  }

  String _getColorCode(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '\x1B[36m';
      case LogLevel.info:
        return '\x1B[32m';
      case LogLevel.warning:
        return '\x1B[33m';
      case LogLevel.error:
        return '\x1B[31m';
    }
  }
}

class LoggerConfig {
  final LogLevel minimumLevel;
  final bool showDebugLogs;
  final List<LogSink> sinks;

  const LoggerConfig({
    this.minimumLevel = LogLevel.debug,
    this.showDebugLogs = true,
    List<LogSink>? sinks,
  }) : sinks = sinks ?? const [];

  LoggerConfig copyWith({
    LogLevel? minimumLevel,
    bool? showDebugLogs,
    List<LogSink>? sinks,
  }) {
    return LoggerConfig(
      minimumLevel: minimumLevel ?? this.minimumLevel,
      showDebugLogs: showDebugLogs ?? this.showDebugLogs,
      sinks: sinks ?? this.sinks,
    );
  }
}

class LoggerService {
  static LoggerService? _instance;
  static LoggerService get instance => _instance ??= LoggerService._();

  LoggerConfig _config;
  final List<LogSink> _sinks = [];

  LoggerService._() : _config = const LoggerConfig() {
    _initializeDefaultSinks();
  }

  void _initializeDefaultSinks() {
    final isDebug = kDebugMode;
    final minimumLevel = isDebug ? LogLevel.debug : LogLevel.info;

    _sinks.add(ConsoleSink(minimumLevel: minimumLevel));
    _config = _config.copyWith(sinks: _sinks);
  }

  void configure(LoggerConfig config) {
    _config = config;
    _sinks.clear();
    _sinks.addAll(config.sinks);
  }

  void addSink(LogSink sink) {
    _sinks.add(sink);
    _config = _config.copyWith(sinks: _sinks);
  }

  void _log(
    LogLevel level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (level.index < _config.minimumLevel.index) return;

    final entry = LogEntry(
      level: level,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );

    for (final sink in _sinks) {
      if (sink.shouldLog(level)) {
        sink.write(entry);
      }
    }
  }

  void debug(String message) => _log(LogLevel.debug, message);

  void info(String message) => _log(LogLevel.info, message);

  void warning(String message) => _log(LogLevel.warning, message);

  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _log(LogLevel.error, message, error, stackTrace);

  void logException(Exception e, {String? context}) {
    final message = context != null
        ? '$context: ${e.toString()}'
        : e.toString();
    _log(LogLevel.error, message, e, StackTrace.current);
  }
}

extension LoggerExtensions on Object {
  void logDebug(LoggerService logger) => logger.debug(toString());
  void logInfo(LoggerService logger) => logger.info(toString());
  void logWarning(LoggerService logger) => logger.warning(toString());
  void logError(
    LoggerService logger, [
    Object? error,
    StackTrace? stackTrace,
  ]) => logger.error(toString(), error, stackTrace);
}
