# AI Feature: Lunch Lens

## What it does
Lunch Lens basically guesses what your next purchase at a meal spot will probably cost. It shows a card with the guess and you can hit Apply to fill in the cost box or Not now to hide it. So it saves you typing and you kind of know what to expect before you buy.

## Inputs
- the past purchase costs for that one meal in cents from the purchase_logs table
- thats it, no personal info and no internet

## How it works
Its rule based not a trained model. It skips any cost thats 0 or less and then it takes the 3 newest costs at that meal and averages them and rounds to the nearest cent. If theres less than 3 good costs it just says "Not enough data yet".

The logic is in lib/helpers/lunch_lens_helper.dart as plain dart functions so its separate from the ui and we could unit test it.

## Why we picked this
An average of a few recent purchases is simple and easy to explain and it works offline. Only using the last 3 means it keeps up if prices change and needing 3 means one purchase doesnt count as a pattern.

## What else we thought about
Using the median of the last 3 instead. It handles one weird big order better (look at the counterexample below).

## Baseline
The last price you paid at that meal.

## User control
- the card says "Smart helper (suggested, not guaranteed)" and shows why, like "Based on your last 3 logs here: $8.50, $9.25, $9.10"
- Apply only fills in the cost box and nothing saves until you hit Log meal
- Not now hides the card
- it all works offline