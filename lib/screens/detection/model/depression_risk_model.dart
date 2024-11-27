class DepressionRiskModel {
  final double physicalActivityScore;
  final double sleepQualityScore;
  final double heartRateVariabilityScore;
  final double totalRiskScore;
  final String riskLevel;
  final int daysWithDepressionIndicators;
  final int totalValidDays;

  DepressionRiskModel({
    required this.physicalActivityScore,
    required this.sleepQualityScore,
    required this.heartRateVariabilityScore,
    required this.totalRiskScore,
    required this.riskLevel,
    required this.daysWithDepressionIndicators,
    required this.totalValidDays,
  });
}
