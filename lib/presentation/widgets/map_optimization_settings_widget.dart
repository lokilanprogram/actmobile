import 'package:flutter/material.dart';
import 'package:acti_mobile/domain/services/map_optimization_service.dart';
import 'dart:developer' as developer;

class MapOptimizationSettingsWidget extends StatefulWidget {
  const MapOptimizationSettingsWidget({super.key});

  @override
  State<MapOptimizationSettingsWidget> createState() =>
      _MapOptimizationSettingsWidgetState();
}

class _MapOptimizationSettingsWidgetState
    extends State<MapOptimizationSettingsWidget> {
  final MapOptimizationService _mapOptimizationService =
      MapOptimizationService();
  bool _preloadTilesEnabled = true;
  bool _isLoading = true;
  Map<String, dynamic> _cacheStats = {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final preloadEnabled =
          await _mapOptimizationService.isPreloadTilesEnabled();
      final cacheStats = await _mapOptimizationService.getCacheStats();

      if (mounted) {
        setState(() {
          _preloadTilesEnabled = preloadEnabled;
          _cacheStats = cacheStats;
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log('Ошибка загрузки настроек: $e',
          name: 'MAP_OPTIMIZATION_SETTINGS');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _togglePreloadTiles(bool value) async {
    try {
      await _mapOptimizationService.setPreloadTilesEnabled(value);
      setState(() {
        _preloadTilesEnabled = value;
      });
    } catch (e) {
      developer.log('Ошибка изменения настройки: $e',
          name: 'MAP_OPTIMIZATION_SETTINGS');
    }
  }

  Future<void> _clearCache() async {
    try {
      await _mapOptimizationService.clearCache();
      await _loadSettings(); // Перезагружаем статистику

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Кэш карты очищен')),
        );
      }
    } catch (e) {
      developer.log('Ошибка очистки кэша: $e',
          name: 'MAP_OPTIMIZATION_SETTINGS');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка очистки кэша')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Оптимизация карты',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Настройка предварительной загрузки
        SwitchListTile(
          title: const Text('Предварительная загрузка тайлов'),
          subtitle:
              const Text('Ускоряет загрузку карты при повторных запусках'),
          value: _preloadTilesEnabled,
          onChanged: _togglePreloadTiles,
        ),

        const SizedBox(height: 16),

        // Статистика кэша
        if (_cacheStats.isNotEmpty) ...[
          const Text(
            'Статистика кэша',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Общий размер: ${_cacheStats['totalSizeMB'] ?? '0'} MB'),
                  if (_cacheStats['tileCache'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                        'Файлов тайлов: ${_cacheStats['tileCache']['fileCount'] ?? 0}'),
                    Text(
                        'Размер тайлов: ${_cacheStats['tileCache']['totalSizeMB'] ?? '0'} MB'),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Кнопка очистки кэша
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _clearCache,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Очистить кэш карты'),
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Информация
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Информация',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '• Предварительная загрузка тайлов ускоряет отображение карты\n'
                  '• Кэш автоматически очищается при превышении 100 MB\n'
                  '• Тайлы автоматически обновляются через 7 дней\n'
                  '• При медленном интернете загрузка может быть отключена',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
