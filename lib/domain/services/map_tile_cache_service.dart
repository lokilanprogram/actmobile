import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'dart:convert';
import 'package:crypto/crypto.dart';

class MapTileCacheService {
  static final MapTileCacheService _instance = MapTileCacheService._internal();
  factory MapTileCacheService() => _instance;
  MapTileCacheService._internal();

  static const String _cacheDirName = 'map_tiles_cache';
  static const int _maxCacheSize = 100 * 1024 * 1024; // 100 MB
  static const Duration _cacheExpiration = Duration(days: 7);

  Directory? _cacheDir;
  bool _isInitialized = false;

  /// Инициализация сервиса
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory('${appDir.path}/$_cacheDirName');

      if (!await _cacheDir!.exists()) {
        await _cacheDir!.create(recursive: true);
      }

      _isInitialized = true;
      developer.log('MapTileCacheService инициализирован', name: 'TILE_CACHE');
    } catch (e) {
      developer.log('Ошибка инициализации MapTileCacheService: $e',
          name: 'TILE_CACHE');
    }
  }

  /// Генерация ключа кэша для URL
  String _generateCacheKey(String url) {
    final bytes = utf8.encode(url);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Получение кэшированного тайла
  Future<File?> getCachedTile(String url) async {
    if (!_isInitialized) await initialize();

    try {
      final cacheKey = _generateCacheKey(url);
      final cacheFile = File('${_cacheDir!.path}/$cacheKey');

      if (await cacheFile.exists()) {
        final stat = await cacheFile.stat();
        final fileAge = DateTime.now().difference(stat.modified);

        // Проверяем, не истек ли срок действия кэша
        if (fileAge < _cacheExpiration) {
          developer.log('Тайл найден в кэше: $url', name: 'TILE_CACHE');
          return cacheFile;
        } else {
          // Удаляем устаревший файл
          await cacheFile.delete();
          developer.log('Удален устаревший тайл: $url', name: 'TILE_CACHE');
        }
      }
    } catch (e) {
      developer.log('Ошибка получения кэшированного тайла: $e',
          name: 'TILE_CACHE');
    }

    return null;
  }

  /// Сохранение тайла в кэш
  Future<void> cacheTile(String url, List<int> tileData) async {
    if (!_isInitialized) await initialize();

    try {
      final cacheKey = _generateCacheKey(url);
      final cacheFile = File('${_cacheDir!.path}/$cacheKey');

      await cacheFile.writeAsBytes(tileData);

      // Проверяем размер кэша и очищаем при необходимости
      await _cleanupCacheIfNeeded();

      developer.log('Тайл сохранен в кэш: $url', name: 'TILE_CACHE');
    } catch (e) {
      developer.log('Ошибка сохранения тайла в кэш: $e', name: 'TILE_CACHE');
    }
  }

  /// Загрузка тайла с кэшированием
  Future<List<int>?> loadTileWithCache(String url) async {
    if (!_isInitialized) await initialize();

    try {
      // Сначала проверяем кэш
      final cachedFile = await getCachedTile(url);
      if (cachedFile != null) {
        return await cachedFile.readAsBytes();
      }

      // Если в кэше нет, загружаем из сети
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final tileData = response.bodyBytes;

        // Сохраняем в кэш
        await cacheTile(url, tileData);

        developer.log('Тайл загружен из сети и кэширован: $url',
            name: 'TILE_CACHE');
        return tileData;
      }
    } catch (e) {
      developer.log('Ошибка загрузки тайла: $e', name: 'TILE_CACHE');
    }

    return null;
  }

  /// Очистка кэша при превышении размера
  Future<void> _cleanupCacheIfNeeded() async {
    if (!_isInitialized) return;

    try {
      final files = await _cacheDir!.list().toList();
      int totalSize = 0;

      // Вычисляем общий размер кэша
      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          totalSize += stat.size;
        }
      }

      // Если размер превышает лимит, удаляем старые файлы
      if (totalSize > _maxCacheSize) {
        final fileStats = <File, DateTime>{};

        for (final file in files) {
          if (file is File) {
            final stat = await file.stat();
            fileStats[file] = stat.modified;
          }
        }

        // Сортируем файлы по дате модификации (старые сначала)
        final sortedFiles = fileStats.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value));

        // Удаляем старые файлы, пока размер не станет приемлемым
        for (final entry in sortedFiles) {
          final stat = await entry.key.stat();
          totalSize -= stat.size;
          await entry.key.delete();

          if (totalSize <= _maxCacheSize * 0.8) {
            // Оставляем 20% запаса
            break;
          }
        }

        developer.log('Кэш очищен, новый размер: ${totalSize ~/ 1024} KB',
            name: 'TILE_CACHE');
      }
    } catch (e) {
      developer.log('Ошибка очистки кэша: $e', name: 'TILE_CACHE');
    }
  }

  /// Получение размера кэша
  Future<int> getCacheSize() async {
    if (!_isInitialized) await initialize();

    try {
      final files = await _cacheDir!.list().toList();
      int totalSize = 0;

      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          totalSize += stat.size;
        }
      }

      return totalSize;
    } catch (e) {
      developer.log('Ошибка получения размера кэша: $e', name: 'TILE_CACHE');
      return 0;
    }
  }

  /// Полная очистка кэша
  Future<void> clearCache() async {
    if (!_isInitialized) await initialize();

    try {
      final files = await _cacheDir!.list().toList();

      for (final file in files) {
        if (file is File) {
          await file.delete();
        }
      }

      developer.log('Кэш тайлов полностью очищен', name: 'TILE_CACHE');
    } catch (e) {
      developer.log('Ошибка очистки кэша: $e', name: 'TILE_CACHE');
    }
  }

  /// Получение статистики кэша
  Future<Map<String, dynamic>> getCacheStats() async {
    if (!_isInitialized) await initialize();

    try {
      final files = await _cacheDir!.list().toList();
      int totalSize = 0;
      int fileCount = 0;
      DateTime? oldestFile;
      DateTime? newestFile;

      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          totalSize += stat.size;
          fileCount++;

          if (oldestFile == null || stat.modified.isBefore(oldestFile)) {
            oldestFile = stat.modified;
          }

          if (newestFile == null || stat.modified.isAfter(newestFile)) {
            newestFile = stat.modified;
          }
        }
      }

      return {
        'fileCount': fileCount,
        'totalSize': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
        'oldestFile': oldestFile?.toIso8601String(),
        'newestFile': newestFile?.toIso8601String(),
        'maxCacheSizeMB': (_maxCacheSize / (1024 * 1024)).toStringAsFixed(2),
      };
    } catch (e) {
      developer.log('Ошибка получения статистики кэша: $e', name: 'TILE_CACHE');
      return {};
    }
  }

  /// Предварительная загрузка тайлов для области
  Future<void> preloadTilesForArea({
    required double centerLat,
    required double centerLng,
    required double radiusKm,
    required int zoomLevel,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      // Вычисляем границы области
      final latDelta = radiusKm / 111.0;
      final lngDelta = radiusKm / (111.0 * cos(centerLat * pi / 180.0));

      final minLat = centerLat - latDelta;
      final maxLat = centerLat + latDelta;
      final minLng = centerLng - lngDelta;
      final maxLng = centerLng + lngDelta;

      // Вычисляем количество тайлов
      final tilesPerSide = 1 << zoomLevel;
      final latTileSize = 180.0 / tilesPerSide;
      final lngTileSize = 360.0 / tilesPerSide;

      final startLatTile = ((90.0 - maxLat) / latTileSize).floor();
      final endLatTile = ((90.0 - minLat) / latTileSize).floor();
      final startLngTile = ((minLng + 180.0) / lngTileSize).floor();
      final endLngTile = ((maxLng + 180.0) / lngTileSize).floor();

      final totalTiles =
          (endLatTile - startLatTile + 1) * (endLngTile - startLngTile + 1);

      // Ограничиваем количество тайлов для предварительной загрузки
      const maxTilesToPreload = 25; // Уменьшаем с 100 до 25 тайлов

      if (totalTiles > maxTilesToPreload) {
        developer.log(
            'Слишком много тайлов для предварительной загрузки: $totalTiles. Ограничиваем до $maxTilesToPreload',
            name: 'TILE_CACHE');

        // Загружаем только центральные тайлы
        final centerLatTile = ((startLatTile + endLatTile) / 2).floor();
        final centerLngTile = ((startLngTile + endLngTile) / 2).floor();
        final tilesPerSide = sqrt(maxTilesToPreload).floor();

        final startLatTileLimited = (centerLatTile - tilesPerSide / 2).floor();
        final endLatTileLimited = (centerLatTile + tilesPerSide / 2).floor();
        final startLngTileLimited = (centerLngTile - tilesPerSide / 2).floor();
        final endLngTileLimited = (centerLngTile + tilesPerSide / 2).floor();

        await _loadTilesInBatches(
          startLatTile: startLatTileLimited,
          endLatTile: endLatTileLimited,
          startLngTile: startLngTileLimited,
          endLngTile: endLngTileLimited,
          zoomLevel: zoomLevel,
        );
      } else {
        await _loadTilesInBatches(
          startLatTile: startLatTile,
          endLatTile: endLatTile,
          startLngTile: startLngTile,
          endLngTile: endLngTile,
          zoomLevel: zoomLevel,
        );
      }
    } catch (e) {
      developer.log('Ошибка предварительной загрузки тайлов: $e',
          name: 'TILE_CACHE');
    }
  }

  /// Загрузка тайлов батчами для избежания перегрузки
  Future<void> _loadTilesInBatches({
    required int startLatTile,
    required int endLatTile,
    required int startLngTile,
    required int endLngTile,
    required int zoomLevel,
  }) async {
    const batchSize = 5; // Уменьшаем с 10 до 5 тайлов одновременно
    const delayBetweenBatches =
        Duration(milliseconds: 200); // Увеличиваем задержку с 100 до 200 мс

    int loadedCount = 0;
    int errorCount = 0;

    for (int latTile = startLatTile; latTile <= endLatTile; latTile++) {
      for (int lngTile = startLngTile; lngTile <= endLngTile; lngTile++) {
        final tileUrl =
            'https://api.mapbox.com/v4/mapbox.streets/$zoomLevel/$lngTile/$latTile.png?access_token=pk.eyJ1IjoiYWN0aSIsImEiOiJjbWE5d2NnZm0xa2w3MmxzZ3J4NmF6YnlzIn0.ZugUX9QGcByj0HzVtbJVgg';

        try {
          // Загружаем тайл асинхронно, не блокируя UI
          await loadTileWithCache(tileUrl);
          loadedCount++;

          // Добавляем задержку каждые batchSize тайлов
          if (loadedCount % batchSize == 0) {
            await Future.delayed(delayBetweenBatches);
          }

          // Останавливаем загрузку при слишком большом количестве ошибок
          if (errorCount > 3) {
            // Уменьшаем с 5 до 3
            developer.log(
                'Слишком много ошибок загрузки тайлов, останавливаем предварительную загрузку',
                name: 'TILE_CACHE');
            break;
          }
        } catch (e) {
          errorCount++;
          developer.log('Ошибка загрузки тайла: $e', name: 'TILE_CACHE');

          // Продолжаем загрузку, но логируем ошибки
          if (errorCount > 5) {
            // Уменьшаем с 10 до 5
            developer.log(
                'Критическое количество ошибок, останавливаем предварительную загрузку',
                name: 'TILE_CACHE');
            break;
          }
        }
      }

      // Проверяем количество ошибок после каждого ряда
      if (errorCount > 5) break; // Уменьшаем с 10 до 5
    }

    developer.log(
        'Предварительная загрузка завершена: загружено $loadedCount тайлов, ошибок: $errorCount',
        name: 'TILE_CACHE');
  }
}
