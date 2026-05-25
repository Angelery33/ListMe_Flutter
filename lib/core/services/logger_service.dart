import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// Niveles de severidad para los mensajes de registro, ordenados de menor a mayor criticidad.
enum LogLevel { debug, info, warning, error }

/// Registro inmutable de un único mensaje de registro junto con sus metadatos.
class LogEntry {
  /// La severidad de esta entrada de registro.
  final LogLevel level;

  /// Descripción del evento legible por humanos.
  final String message;

  /// Objeto de error opcional asociado con esta entrada.
  final Object? error;

  /// Traza de pila opcional capturada en el momento del registro.
  final StackTrace? stackTrace;

  /// Cuándo se creó la entrada; por defecto es [DateTime.now].
  final DateTime timestamp;

  LogEntry({
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Contrato para objetos que pueden recibir y filtrar registros [LogEntry].
abstract class LogSink {
  /// Escribe [entry] en el medio de salida subyacente.
  void write(LogEntry entry);

  /// Devuelve `true` cuando este sink debe procesar entradas en el [level] dado.
  bool shouldLog(LogLevel level);
}

/// Implementación de [LogSink] que formatea las entradas de registro con códigos de color ANSI
/// y las imprime a través de [debugPrint].
class ConsoleSink implements LogSink {
  /// Las entradas por debajo de este nivel se omiten silenciosamente.
  final LogLevel minimumLevel;

  const ConsoleSink({this.minimumLevel = LogLevel.debug});

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

/// Configuración inmutable para [LoggerService].
class LoggerConfig {
  /// Nivel mínimo que procesará el servicio.
  final LogLevel minimumLevel;

  /// Indica si se deben emitir mensajes de depuración detallados.
  final bool showDebugLogs;

  /// La lista de sinks que recibirán las entradas de registro.
  final List<LogSink> sinks;

  const LoggerConfig({
    this.minimumLevel = LogLevel.debug,
    this.showDebugLogs = true,
    List<LogSink>? sinks,
  }) : sinks = sinks ?? const [];

  /// Devuelve una copia de esta configuración con los campos dados sobrescritos.
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

/// Singleton de registro para toda la aplicación.
///
/// Despacha las entradas de registro a un conjunto configurable de objetos [LogSink]. En compilaciones
/// de depuración, se añade automáticamente un [ConsoleSink] en [LogLevel.debug]; en compilaciones
/// de producción, el nivel mínimo se eleva a [LogLevel.info] para reducir el ruido.
///
/// Uso:
/// ```dart
/// final log = LoggerService.instance;
/// log.info('App iniciada');
/// log.error('Algo falló', e, stackTrace);
/// ```
class LoggerService {
  static LoggerService? _instance;

  /// Devuelve el singleton [LoggerService], creándolo en el primer acceso.
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

  /// Reemplaza la configuración actual y la lista de sinks con [config].
  ///
  /// [config] La nueva [LoggerConfig] a aplicar.
  void configure(LoggerConfig config) {
    _config = config;
    _sinks.clear();
    _sinks.addAll(config.sinks);
  }

  /// Añade [sink] a la lista de sinks activos y actualiza la configuración.
  ///
  /// [sink] El [LogSink] a registrar.
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

  /// Registra [message] con severidad [LogLevel.debug].
  void debug(String message) => _log(LogLevel.debug, message);

  /// Registra [message] con severidad [LogLevel.info].
  void info(String message) => _log(LogLevel.info, message);

  /// Registra [message] con severidad [LogLevel.warning].
  void warning(String message) => _log(LogLevel.warning, message);

  /// Registra [message] con severidad [LogLevel.error], opcionalmente con un objeto
  /// [error] y [stackTrace].
  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _log(LogLevel.error, message, error, stackTrace);

  /// Registra [e] como un error, opcionalmente prefijado con una etiqueta de [context].
  ///
  /// [e] The exception to log.
  /// [context] Optional description of the operation that threw [e].
  void logException(Exception e, {String? context}) {
    final message = context != null
        ? '$context: ${e.toString()}'
        : e.toString();
    _log(LogLevel.error, message, e, StackTrace.current);
  }
}

/// Extensión de conveniencia que añade métodos de registro abreviados a cualquier [Object].
extension LoggerExtensions on Object {
  /// Registra el [toString] de este objeto en [LogLevel.debug] a través de [logger].
  void logDebug(LoggerService logger) => logger.debug(toString());

  /// Registra el [toString] de este objeto en [LogLevel.info] a través de [logger].
  void logInfo(LoggerService logger) => logger.info(toString());

  /// Registra el [toString] de este objeto en [LogLevel.warning] a través de [logger].
  void logWarning(LoggerService logger) => logger.warning(toString());

  /// Registra el [toString] de este objeto en [LogLevel.error] a través de [logger], con un
  /// objeto [error] opcional y [stackTrace].
  void logError(
    LoggerService logger, [
    Object? error,
    StackTrace? stackTrace,
  ]) => logger.error(toString(), error, stackTrace);
}
