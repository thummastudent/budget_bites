import 'package:flutter_test/flutter_test.dart';
import 'package:budget_bites/helpers/lunch_lens_helper.dart';

// this part tests lunch lens with made up prices so we know it gives the right guess
// all the costs are in cents and the newest one is first like the database gives them
void main() {
  // this part is a normal case with 3 good purchases
  test('normal: averages the last 3 costs', () {
    List<int> costs = [910, 925, 850]; // $9.10 then $9.25 then $8.50
    LunchLensResult result = estimateNextMeal(costs);

    expect(result.estimateCents, 895); // the average should be $8.95
    expect(result.baselineCents, 910); // the last price should be $9.10
    expect(result.reason, contains('8.50')); // the reason should show the prices it used
  });

  // this part checks what happens with no purchases at all
  test('no data: says not enough data', () {
    List<int> costs = [];
    LunchLensResult result = estimateNextMeal(costs);

    expect(result.hasEstimate, false);
    expect(result.reason, 'Not enough data yet');
  });

  // this part checks 2 purchases is still not enough since we need 3
  test('boundary: 2 logs is still not enough', () {
    List<int> costs = [900, 800];
    LunchLensResult result = estimateNextMeal(costs);

    expect(result.hasEstimate, false);
  });

  // this part checks bad costs like 0 or negative get skipped
  test('invalid: skips 0 and negative costs', () {
    List<int> costs = [900, 0, -500, 850, 800];
    LunchLensResult result = estimateNextMeal(costs);

    expect(result.estimateCents, 850); // it should only use 900 and 850 and 800
  });

  // this part checks that if bad costs get skipped and theres less than 3 left its not enough
  test('invalid: not enough data after skipping bad costs', () {
    List<int> costs = [900, 0, 800];
    LunchLensResult result = estimateNextMeal(costs);

    expect(result.hasEstimate, false);
  });

  // this part checks one big group order pulls the guess way up
  test('outlier: one expensive group order pulls the guess up', () {
    List<int> costs = [2700, 900, 900]; // a $27 group order then two $9 meals
    
    LunchLensResult result = estimateNextMeal(costs);

     expect(result.estimateCents, 1500); // $15 is way too high for a normal meal
  });

  // this part is where the baseline does better than the average
  
  test('counterexample: price went up so the baseline wins', () {
      List<int> costs = [1200, 800, 800]; // the menu price went up to $12
      LunchLensResult result = estimateNextMeal(costs);

      expect(result.estimateCents, 933); // the average says $9.33 which is too low now
      expect(result.baselineCents, 1200); // the last price says $12 which is right
  });

  // this part checks it only uses the 3 newest and ignores older ones
  test('only uses the 3 newest costs', () {
    List<int> costs = [1000, 1000, 1000, 5000];
    LunchLensResult result = estimateNextMeal(costs);

    expect(result.estimateCents, 1000);
  });
}