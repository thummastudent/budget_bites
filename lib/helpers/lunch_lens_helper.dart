// lunch lens guesses how much your next purchase at a meal might cost
// it uses your last 3 purchases to find an average

class LunchLensResult {
  final int? estimateCents; // this part is the guess in cents so its null if theres not enough data
  final int? baselineCents; // this part is the last price you paid so we can compare it to the guess
  final List<int> costsUsed; // this part is the costs that went into the average so we can show them
  final String reason; // this part is the text on the card so the user knows why

  const LunchLensResult({
    required this.estimateCents,
    required this.baselineCents,
    required this.costsUsed,
    required this.reason,
  });

  // this part checks if there is a guess so the card knows what to show
  bool get hasEstimate {
    return estimateCents != null;
  }
}



// this part turns cents into dollars so 895 shows up as $8.95
String formatMoney(int cents) {
  double dollars = cents / 100; // 895 becomes 8.95
  String withTwoDecimals = dollars.toStringAsFixed(2); // so 8.5 shows as 8.50
  return '\$' + withTwoDecimals; // put the dollar sign in front
}


// this part is how many purchases we need before we guess
const int logsNeeded = 3;

// this part is what we send back when theres not enough purchases so we dont have to write it twice
LunchLensResult notEnoughData() {
  return const LunchLensResult(
    estimateCents: null,
    baselineCents: null,
    costsUsed: [],
    reason: 'Not enough data yet',
  );
}

// this part makes the guess so costsNewestFirst is the past costs in cents with the newest one first
LunchLensResult estimateNextMeal(List<int> costsNewestFirst) {
  // this part stops early if theres less than 3 purchases so its not really a pattern yet
  if (costsNewestFirst.length < logsNeeded) {
    return notEnoughData();
  }

  // this part grabs the 3 newest costs
  List<int> recent = [];
  int i = 0;
  while (i < logsNeeded) {
    recent.add(costsNewestFirst[i]);
    i++;
  }

  // this part adds them up and divides so we get the average
  int total = 0;
  int j = 0;
  while (j < recent.length) {
    total += recent[j];
    j++;
  }
  int estimate = (total / recent.length).round(); // round so its a whole number of cents

  return LunchLensResult(
    estimateCents: estimate,
    baselineCents: recent[0], // this part is the last price you paid so we can compare it to the average
    costsUsed: recent,
    reason: 'Based on your last 3 logs here',
  );
}
