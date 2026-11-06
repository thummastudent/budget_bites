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
}