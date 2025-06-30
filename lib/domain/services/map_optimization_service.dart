import 'dart:io';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'dart:convert';
import 'map_tile_cache_service.dart';

class MapOptimizationService {
  static final MapOptimizationService _instance =
      MapOptimizationService._internal();
  factory MapOptimizationService() => _instance;
  MapOptimizationService._internal();

  static const String _lastLocationKey = 'last_known_location';
  static const String _mapStyleCacheKey = 'map_style_cache';
  static const String _userPreferencesKey = 'user_map_preferences';
  static const String _preloadTilesKey = 'preload_tiles_enabled';

  bool _isInitialized = false;
  String? _cachedStyleJson;

  // Сервис кэширования тайлов
  final MapTileCacheService _tileCacheService = MapTileCacheService();

  /// Инициализация сервиса
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadCachedData();
      await _tileCacheService.initialize();
      _isInitialized = true;
      developer.log('MapOptimizationService инициализирован',
          name: 'MAP_OPTIMIZATION');
    } catch (e) {
      developer.log('Ошибка инициализации MapOptimizationService: $e',
          name: 'MAP_OPTIMIZATION');
    }
  }

  /// Загрузка кэшированных данных
  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedStyleJson = prefs.getString(_mapStyleCacheKey);
      developer.log('Кэшированные данные загружены', name: 'MAP_OPTIMIZATION');
    } catch (e) {
      developer.log('Ошибка загрузки кэшированных данных: $e',
          name: 'MAP_OPTIMIZATION');
    }
  }

  /// Сохранение последней известной локации
  Future<void> saveLastLocation(double latitude, double longitude) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationData = {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await prefs.setString(_lastLocationKey, jsonEncode(locationData));
      developer.log('Последняя локация сохранена: $latitude, $longitude',
          name: 'MAP_OPTIMIZATION');
    } catch (e) {
      developer.log('Ошибка сохранения локации: $e', name: 'MAP_OPTIMIZATION');
    }
  }

  /// Получение последней известной локации
  Future<Map<String, double>?> getLastLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationString = prefs.getString(_lastLocationKey);

      if (locationString != null) {
        final locationData = jsonDecode(locationString) as Map<String, dynamic>;
        final timestamp = locationData['timestamp'] as int;
        final locationTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

        // Проверяем, что данные не старше 24 часов
        if (DateTime.now().difference(locationTime).inHours < 24) {
          return {
            'latitude': locationData['latitude'] as double,
            'longitude': locationData['longitude'] as double,
          };
        }
      }
    } catch (e) {
      developer.log('Ошибка получения последней локации: $e',
          name: 'MAP_OPTIMIZATION');
    }
    return null;
  }

  /// Кэширование стиля карты
  Future<void> cacheMapStyle(String styleJson) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_mapStyleCacheKey, styleJson);
      _cachedStyleJson = styleJson;
      developer.log('Стиль карты закэширован', name: 'MAP_OPTIMIZATION');
    } catch (e) {
      developer.log('Ошибка кэширования стиля: $e', name: 'MAP_OPTIMIZATION');
    }
  }

  /// Получение кэшированного стиля
  String? getCachedStyle() {
    return _cachedStyleJson;
  }

  /// Предварительная загрузка данных для быстрого старта
  Future<void> preloadMapData() async {
    if (!_isInitialized) await initialize();

    try {
      // Проверяем, включена ли предварительная загрузка тайлов
      final preloadEnabled = await isPreloadTilesEnabled();
      if (!preloadEnabled) {
        developer.log('Предварительная загрузка тайлов отключена пользователем',
            name: 'MAP_OPTIMIZATION');
        // Загружаем только базовые данные
        await _preloadMapStyle();
        await _saveUserPreferences();
        return;
      }

      // Проверяем качество интернет-соединения
      final isOnline = await isInternetAvailable();
      if (!isOnline) {
        developer.log(
            'Интернет недоступен, пропускаем предварительную загрузку тайлов',
            name: 'MAP_OPTIMIZATION');
        // Загружаем только базовые данные
        await _preloadMapStyle();
        await _saveUserPreferences();
        return;
      }

      // 1. Получаем текущую локацию и сохраняем её (с таймаутом)
      try {
        final position = await geolocator.Geolocator.getCurrentPosition(
          timeLimit: const Duration(seconds: 5), // Добавляем таймаут
        );
        await saveLastLocation(position.latitude, position.longitude);

        // 2. Предварительно загружаем тайлы для текущей локации (уменьшенная область)
        // Запускаем в фоне, не блокируя основной поток
        Future.microtask(() async {
          try {
            await _tileCacheService.preloadTilesForArea(
              centerLat: position.latitude,
              centerLng: position.longitude,
              radiusKm: 5.0, // Уменьшаем с 10 до 5 км
              zoomLevel: 13, // Уменьшаем с 14 до 13
            );
          } catch (e) {
            developer.log('Ошибка предварительной загрузки тайлов: $e',
                name: 'MAP_OPTIMIZATION');
          }
        });
      } catch (e) {
        developer.log('Не удалось получить текущую локацию: $e',
            name: 'MAP_OPTIMIZATION');

        // Если не удалось получить локацию, загружаем тайлы для Москвы (уменьшенная область)
        Future.microtask(() async {
          try {
            await _tileCacheService.preloadTilesForArea(
              centerLat: 55.7558,
              centerLng: 37.6173,
              radiusKm: 5.0, // Уменьшаем с 10 до 5 км
              zoomLevel: 13, // Уменьшаем с 14 до 13
            );
          } catch (e) {
            developer.log(
                'Ошибка предварительной загрузки тайлов для Москвы: $e',
                name: 'MAP_OPTIMIZATION');
          }
        });
      }

      // 3. Предварительно загружаем стиль карты
      await _preloadMapStyle();

      // 4. Сохраняем пользовательские настройки
      await _saveUserPreferences();

      developer.log('Предварительная загрузка данных карты завершена',
          name: 'MAP_OPTIMIZATION');
    } catch (e) {
      developer.log('Ошибка предварительной загрузки: $e',
          name: 'MAP_OPTIMIZATION');
    }
  }

  /// Предварительная загрузка стиля карты
  Future<void> _preloadMapStyle() async {
    try {
      // Здесь можно предварительно загрузить стиль карты
      // и сохранить его в кэше
      const defaultStyle = 'mapbox://styles/acti/cmbf00t92005701s5d84c1cqp';
      await cacheMapStyle(defaultStyle);
    } catch (e) {
      developer.log('Ошибка предварительной загрузки стиля: $e',
          name: 'MAP_OPTIMIZATION');
    }
  }

  /// Сохранение пользовательских настроек карты
  Future<void> _saveUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final preferences = {
        'last_zoom': 16.0,
        'preferred_style': 'mapbox://styles/acti/cmbf00t92005701s5d84c1cqp',
        'map_controls_enabled': true,
      };
      await prefs.setString(_userPreferencesKey, jsonEncode(preferences));
    } catch (e) {
      developer.log('Ошибка сохранения настроек: $e', name: 'MAP_OPTIMIZATION');
    }
  }

  /// Получение пользовательских настроек
  Future<Map<String, dynamic>?> getUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final preferencesString = prefs.getString(_userPreferencesKey);

      if (preferencesString != null) {
        return jsonDecode(preferencesString) as Map<String, dynamic>;
      }
    } catch (e) {
      developer.log('Ошибка получения настроек: $e', name: 'MAP_OPTIMIZATION');
    }
    return null;
  }

  /// Оптимизированные настройки камеры
  Future<CameraOptions> getOptimizedCameraOptions({
    double? latitude,
    double? longitude,
    double? zoom,
  }) async {
    // Получаем последнюю известную локацию или используем Москву по умолчанию
    final lastLocation = await getLastLocation();

    final lat = latitude ?? lastLocation?['latitude'] ?? 55.7558;
    final lng = longitude ?? lastLocation?['longitude'] ?? 37.6173;
    final z = zoom ?? 16.0;

    return CameraOptions(
      center: Point(coordinates: Position(lng, lat)),
      zoom: z,
      bearing: 0.0,
      pitch: 0.0,
    );
  }

  /// Оптимизированные настройки жестов
  GesturesSettings getOptimizedGesturesSettings() {
    return GesturesSettings(
      pinchToZoomEnabled: true,
      doubleTapToZoomInEnabled: true,
      doubleTouchToZoomOutEnabled: true,
      scrollEnabled: true,
      rotateEnabled: true,
      pitchEnabled: true,
    );
  }

  /// Очистка кэша
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_mapStyleCacheKey);
      await prefs.remove(_lastLocationKey);
      await prefs.remove(_userPreferencesKey);

      // Очищаем кэш тайлов
      await _tileCacheService.clearCache();

      _cachedStyleJson = null;
      developer.log('Кэш карты очищен', name: 'MAP_OPTIMIZATION');
    } catch (e) {
      developer.log('Ошибка очистки кэша: $e', name: 'MAP_OPTIMIZATION');
    }
  }

  /// Получение размера кэша
  Future<int> getCacheSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int totalSize = 0;

      final styleCache = prefs.getString(_mapStyleCacheKey);
      if (styleCache != null) {
        totalSize += styleCache.length;
      }

      final locationCache = prefs.getString(_lastLocationKey);
      if (locationCache != null) {
        totalSize += locationCache.length;
      }

      final preferencesCache = prefs.getString(_userPreferencesKey);
      if (preferencesCache != null) {
        totalSize += preferencesCache.length;
      }

      // Добавляем размер кэша тайлов
      totalSize += await _tileCacheService.getCacheSize();

      return totalSize;
    } catch (e) {
      developer.log('Ошибка получения размера кэша: $e',
          name: 'MAP_OPTIMIZATION');
      return 0;
    }
  }

  /// Получение статистики кэша
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final tileStats = await _tileCacheService.getCacheStats();
      final totalSize = await getCacheSize();

      return {
        'totalSize': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
        'tileCache': tileStats,
      };
    } catch (e) {
      developer.log('Ошибка получения статистики кэша: $e',
          name: 'MAP_OPTIMIZATION');
      return {};
    }
  }

  /// Проверка доступности интернета
  Future<bool> isInternetAvailable() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Оптимизация для медленного интернета
  Future<void> optimizeForSlowConnection() async {
    try {
      // Уменьшаем качество изображений и отключаем некоторые функции
      final prefs = await SharedPreferences.getInstance();
      final slowConnectionSettings = {
        'low_quality_mode': true,
        'disable_animations': true,
        'reduce_tile_quality': true,
      };
      await prefs.setString(
          'slow_connection_settings', jsonEncode(slowConnectionSettings));
      developer.log('Настройки для медленного соединения применены',
          name: 'MAP_OPTIMIZATION');
    } catch (e) {
      developer.log('Ошибка применения настроек для медленного соединения: $e',
          name: 'MAP_OPTIMIZATION');
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
      await _tileCacheService.preloadTilesForArea(
        centerLat: centerLat,
        centerLng: centerLng,
        radiusKm: radiusKm,
        zoomLevel: zoomLevel,
      );
    } catch (e) {
      developer.log('Ошибка предварительной загрузки тайлов: $e',
          name: 'MAP_OPTIMIZATION');
    }
  }

  /// Проверка, включена ли предварительная загрузка тайлов
  Future<bool> isPreloadTilesEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_preloadTilesKey) ?? true; // По умолчанию включено
    } catch (e) {
      return true; // По умолчанию включено
    }
  }

  /// Включение/отключение предварительной загрузки тайлов
  Future<void> setPreloadTilesEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_preloadTilesKey, enabled);
      developer.log(
          'Предварительная загрузка тайлов ${enabled ? 'включена' : 'отключена'}',
          name: 'MAP_OPTIMIZATION');
    } catch (e) {
      developer.log('Ошибка изменения настройки предварительной загрузки: $e',
          name: 'MAP_OPTIMIZATION');
    }
  }

  /// Быстрая инициализация без предварительной загрузки тайлов
  Future<void> quickInitialize() async {
    if (_isInitialized) return;

    try {
      await _loadCachedData();
      await _tileCacheService.initialize();
      _isInitialized = true;
      developer.log('MapOptimizationService быстро инициализирован',
          name: 'MAP_OPTIMIZATION');
    } catch (e) {
      developer.log('Ошибка быстрой инициализации MapOptimizationService: $e',
          name: 'MAP_OPTIMIZATION');
    }
  }

  /// Оптимизированные настройки камеры с быстрой загрузкой
  Future<CameraOptions> getQuickCameraOptions({
    double? latitude,
    double? longitude,
    double? zoom,
  }) async {
    // Сначала пытаемся получить кэшированную локацию
    final lastLocation = await getLastLocation();

    final lat = latitude ?? lastLocation?['latitude'] ?? 55.7558;
    final lng = longitude ?? lastLocation?['longitude'] ?? 37.6173;
    final z = zoom ?? 15.0; // Уменьшаем зум для быстрой загрузки

    return CameraOptions(
      center: Point(coordinates: Position(lng, lat)),
      zoom: z,
      bearing: 0.0,
      pitch: 0.0,
    );
  }

  /// Проверка, готов ли сервис к использованию
  bool get isReady => _isInitialized;

  /// Надёжное получение геолокации с fallback на кэш и дефолт (Москва)
  Future<Map<String, double>> getReliableLocation(
      {Duration fastTimeout = const Duration(seconds: 5),
      Duration slowTimeout = const Duration(seconds: 15)}) async {
    try {
      // Быстрая попытка
      print(
          '[GEO] Быстрая попытка получить позицию (таймаут ${fastTimeout.inSeconds} сек)');
      final position = await geolocator.Geolocator.getCurrentPosition(
        timeLimit: fastTimeout,
      );
      print(
          '[GEO] Успешно получена позиция: [32m${position.latitude}, ${position.longitude}[0m');
      await saveLastLocation(position.latitude, position.longitude);
      return {'latitude': position.latitude, 'longitude': position.longitude};
    } catch (e) {
      print('[GEO] Ошибка быстрой попытки: $e');
      try {
        // Медленная попытка
        print(
            '[GEO] Медленная попытка получить позицию (таймаут ${slowTimeout.inSeconds} сек)');
        final position = await geolocator.Geolocator.getCurrentPosition(
          timeLimit: slowTimeout,
        );
        print(
            '[GEO] Успешно получена позиция (slow): [32m${position.latitude}, ${position.longitude}[0m');
        await saveLastLocation(position.latitude, position.longitude);
        return {'latitude': position.latitude, 'longitude': position.longitude};
      } catch (e2) {
        print('[GEO] Ошибка медленной попытки: $e2');
        // Fallback на кэш
        final last = await getLastLocation();
        if (last != null) {
          print(
              '[GEO] Используем кэшированную позицию: [33m${last['latitude']}, ${last['longitude']} (fallback)\u001b[0m');
          return last;
        }
        print('[GEO] Используем Москву по умолчанию (fallback)');
        return {'latitude': 55.7558, 'longitude': 37.6173};
      }
    }
  }
}
