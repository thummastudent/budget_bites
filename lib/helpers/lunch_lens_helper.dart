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