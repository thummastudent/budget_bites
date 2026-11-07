# Budget Bites

So Budget Bites is basically a simple offline Flutter app for students to keep track of how much they spend on food. You save the places you usually eat, log what you spend there, and see how close you are to your weekly budget. It also has a smart helper called Lunch Lens that kind of guesses what your next meal at a place is gonna cost.

## Team
| Name | What they did |
|---|---|
| Deepak Thumma | database helper, meal form, dashboard, details screen with purchase logging, history screen, settings, navigation |
| Saurav Annepu | proposal, Lunch Lens helper, Lunch Lens card, Lunch Lens unit tests, history refresh fix, docs (README, ARCHITECTURE, AI_FEATURE, AI_Usage_Log) |

## Features
- Add, edit and delete meals (name, cuisine, venue note, target price)
- Log what you spent at a meal and see the total for that place
- If you delete a meal its purchases get deleted too (it asks you to confirm first)
- Cuisine filter on the dashboard
- History screen with a filter, total spent and average per purchase
- Weekly budget slider in Settings (saved with SharedPreferences so it stays after you close the app)
- Lunch Lens smart helper that guesses your next meal cost (more in AI_FEATURE.md)
- Everything works offline, nothing goes to the cloud

## Setup
1. Install Flutter (we used version 3.47.2)
2. Clone the repo: `git clone https://github.com/thummastudent/budget_bites`
3. `cd budget_bites`
4. `flutter pub get`
5. Start an Android emulator and run `flutter run`

To build the APK: `flutter build apk --release`

To run the Lunch Lens tests: `flutter test test/lunch_lens_helper_test.dart`

## How to use
1. Tap Add Meal to save a place you eat at
2. Tap a meal to open its details and log what you spent
3. After 3 purchases Lunch Lens shows a guess. Tap Apply to put it in the cost box or Not now to hide it
4. Check History to see your totals
5. Set your weekly budget in Settings

## Packages
- sqflite (the SQLite database)
- path (for the database file path)
- shared_preferences (for settings)

## Database
So there are 2 tables:
- `meals`: id, name, venue_note, cuisine, estimated_price_minor
- `purchase_logs`: id, meal_id (foreign key to meals with ON DELETE CASCADE), purchased_at, actual_price_minor, note

Prices are saved in cents so there are no rounding problems with decimals.

## Project evidence
- Video presentation: https://drive.google.com/file/d/19D1yLYTKvJpYu0a-JOd6gqb5GUnjjO6i/view?usp=sharing
- ClickUp board: https://app.clickup.com/90141800628/v/li/901422607876
- Kanban evidence: Kanban_Contribution_Evidence.pdf (in the submission zip)
- Architecture: ARCHITECTURE.md
- Smart helper: AI_FEATURE.md
- AI help: AI_Usage_Log.md

## Known issues
- One big group order kind of throws off the Lunch Lens guess for the next few purchases (more in AI_FEATURE.md)
- Lunch Lens is slow to catch it when a place raises its prices
- The History filter chips (Fast Food, Dining, Grocery, Other) dont match the meal cuisines yet so only All shows logs

## Future ideas
- Use the median in Lunch Lens so one weird price doesn't mess it up as much
- Let you mark a purchase as a group order
- Charts for spending over time
- Export your data to CSV

## License
For CSC 4360 coursework at Georgia State University.