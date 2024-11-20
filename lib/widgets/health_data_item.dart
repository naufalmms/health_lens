import 'package:flutter/material.dart';
import 'package:health/health.dart';

class HealthDataItem extends StatelessWidget {
  final HealthDataPoint data;

  const HealthDataItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(_getTitle()),
        subtitle: Text(_formatDate()),
        trailing: Text(_getValue()),
      ),
    );
  }

  String _getTitle() {
    return data.typeString;
  }

  String _getValue() {
    if (data.value is AudiogramHealthValue) {
      return 'Audiogram';
    } else if (data.value is WorkoutHealthValue) {
      final workout = data.value as WorkoutHealthValue;
      return '${workout.totalEnergyBurned} ${workout.totalEnergyBurnedUnit?.name}';
    } else if (data.value is NutritionHealthValue) {
      final nutrition = data.value as NutritionHealthValue;
      return '${nutrition.calories} kcal';
    }
    return '${data.value} ${data.unitString}';
  }

  String _formatDate() {
    return '${data.dateFrom.toString().split('.')[0]} - ${data.dateTo.toString().split('.')[0]}';
  }
}
