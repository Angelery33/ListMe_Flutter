import 'package:flutter/material.dart';

/// Utilidades para trasladar los datos devueltos por [SearchImportScreen] al
/// formulario de entrada de ítems.
///
/// Todos los métodos son estáticos y no tienen estado.
class ItemImportMapper {
  ItemImportMapper._();

  /// Rellena los [TextEditingController]s de progreso (páginas, capítulos,
  /// volúmenes, temporadas) con los valores del mapa [result] devuelto por la
  /// búsqueda externa, únicamente cuando el controller todavía está vacío para
  /// no sobrescribir lo que el usuario haya introducido manualmente.
  static void applyProgressFields(
    Map<String, dynamic> result, {
    required TextEditingController totalPage,
    required TextEditingController totalChapter,
    required TextEditingController totalVolume,
    required TextEditingController totalSeason,
  }) {
    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    final page = toInt(result['totalPage']);
    if (page != null && page > 0 && totalPage.text.isEmpty) {
      totalPage.text = page.toString();
    }

    final chapter = toInt(result['totalChapter']) ??
        toInt(result['totalChapters']) ??
        toInt(result['lastChapter']) ??
        toInt(result['chapters']) ??
        toInt(result['episodes']) ??
        toInt(result['totalEpisodes']);
    if (chapter != null && chapter > 0 && totalChapter.text.isEmpty) {
      totalChapter.text = chapter.toString();
    }

    final volume = toInt(result['totalVolume']) ??
        toInt(result['totalVolumes']) ??
        toInt(result['volumes']);
    if (volume != null && volume > 0 && totalVolume.text.isEmpty) {
      totalVolume.text = volume.toString();
    }

    final season = toInt(result['totalSeason']) ?? toInt(result['seasons']);
    if (season != null && season > 0 && totalSeason.text.isEmpty) {
      totalSeason.text = season.toString();
    }
  }

  /// Recopila los campos de metadatos conocidos de [result] y los devuelve como
  /// un mapa nombre→valor listo para guardarse como atributos del ítem.
  ///
  /// Los valores que sean `null`, vacíos, `'N/A'` o `'0'` se omiten.
  static Map<String, String> collectAttributes(Map<String, dynamic> result) {
    final attrs = <String, String>{};

    void add(String name, dynamic value) {
      if (value == null) return;
      final str = value.toString().trim();
      if (str.isEmpty || str == 'N/A' || str == '0') return;
      attrs[name] = str;
    }

    add('Autor', result['author']);
    add('Director', result['director']);
    add('Reparto', result['actors']);
    add('Guionista', result['writer']);
    add('Estudio', result['studio']);
    add('Editorial', result['publisher']);
    add('Año', result['year']);
    add('Idioma', result['language']);
    add('País', result['country']);
    add('ISBN', result['isbn']);
    add('IMDb ID', result['imdbId']);
    add('Eslogan', result['tagline']);

    final runtime = result['runtime'];
    if (runtime != null) {
      final r = runtime is int ? runtime : int.tryParse(runtime.toString());
      if (r != null && r > 0) attrs['Duración'] = '$r min';
    }

    final duration = result['durationMinutes'];
    if (duration != null) {
      final d = duration is int ? duration : int.tryParse(duration.toString());
      if (d != null && d > 0) attrs['Duración/Episodio'] = '$d min';
    }

    final nameJa = result['nameJapanese'];
    if (nameJa != null && nameJa.toString().trim().isNotEmpty) {
      attrs['Título Japonés'] = nameJa.toString();
    }
    final nameEn = result['nameEnglish'];
    if (nameEn != null && nameEn.toString().trim().isNotEmpty) {
      attrs['Título Inglés'] = nameEn.toString();
    }

    return attrs;
  }
}
