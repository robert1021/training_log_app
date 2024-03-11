import 'dart:math';

class OneRepMaxCalculator {
  final double weight;
  final int reps;

  OneRepMaxCalculator({
    required this.weight,
    required this.reps});


  // Weight × (36 / (37 – number of reps))
  double getOneRepMaxBrzyckiFormula() {
    return weight * (36.0 / (37.0 - reps.toDouble()));
  }

  // Weight × (1 + (0.0333 × number of reps))
  double getOneRepMaxEpleyFormula() {
    return weight * (1 + (0.0333 * reps.toDouble()));
  }

  // Weight × (number of reps ^ 0.1)
  double getOneRepMaxLombardiFormula() {
    return weight * (pow(reps.toDouble(), 0.1));
  }

  // Weight × (1 + (0.025 × number of reps))
  double getOneRepMaxOconnerFormula() {
    return weight * (1 + (0.025 * reps.toDouble()));
  }

}