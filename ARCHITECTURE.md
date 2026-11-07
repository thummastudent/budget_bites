# Budget Bites Architecture

## 1. How the app is set up
We kept the folders simple and didnt use stuff like dependency injection or a repository pattern since thats for the grad students.

| Folder | Whats in it |
|---|---|
| `lib/screens` | the 5 screens which are Dashboard, Meal Form, Details (shows one meals purchases and has the log purchase form), History and Settings |
| `lib/widgets` | `LunchLensCard` which is the smart helper card. `DashboardCard` is also a reusable widget but its inside `dashboard.dart` |
| `lib/models` | the `Meal` and `PurchaseLog` classes and they have `toMap()` and `fromMap()` |
| `lib/database` | `DatabaseHelper` which basically owns the sqlite connection and all the queries |
| `lib/helpers` | `lunch_lens_helper.dart` which has the smart helper logic as plain dart functions |

The screens never write sql themselves. They just call `DatabaseHelper`, get the rows back and turn them into `Meal` or `PurchaseLog` objects with `fromMap()`.

## 2. Navigation
The app has a bottom nav bar with Dashboard, History and Settings.
- from the Dashboard you can add or edit a meal in the Meal Form or tap a meal to open its Details screen
- the Details screen has the log purchase form and the Lunch Lens card and that meals purchases
- the Meal Form sends back `true` when it saves so the Dashboard reloads, and the Details screen reloads its own list after you log or delete a purchase

## 3. State and lifecycle
- each screen keeps its own state with `StatefulWidget` and `setState()`. We didnt use Provider or Riverpod or BLoC since its an undergrad project and each screen kind of owns its own data anyway
- screens load their data from sqlite when they open in `initState()`. The Dashboard and Settings use `setState()` with the results and the Details screen uses a `FutureBuilder`
- the async stuff checks `if (!mounted) return;` before `setState()` so nothing tries to update after you already left the screen
- forms get rid of their `TextEditingController`s in `dispose()` so theres no memory leaks
- `DashboardCard` is a `StatelessWidget` since it just shows data and `LunchLensCard` is a `StatefulWidget` because it has to remember if you hit Not now
- whatever you type in a form is just temporary and it only becomes a saved record when you hit Save or Log meal

## 4. Local data
### SQLite (sqflite)
Theres two tables that are connected:
- `meals` is the parent and has id, name, venue_note, cuisine and estimated_price_minor
- `purchase_logs` is the child and has id, meal_id, purchased_at, actual_price_minor and note

`meal_id` is a foreign key to `meals.id` with `ON DELETE CASCADE`. We turn on `PRAGMA foreign_keys = ON` in `onConfigure` because sqlite basically ignores foreign keys if you dont. So if you delete a meal its purchases get deleted too and the confirm dialog warns you first.

Prices are saved as whole numbers in cents so theres no weird rounding stuff and they only get turned into dollars when we show them.

Every query that uses a value goes through `whereArgs` so what the user types never goes straight into the sql.

### SharedPreferences
Small settings like the weekly budget go here instead of sqlite since theyre just single values with nothing connected to them. They stay saved after you close and reopen the app.

Nothing gets saved to the cloud and the whole app works offline.

## 5. Smart helper (Lunch Lens)
The logic is in `lib/helpers/lunch_lens_helper.dart`. `estimateNextMeal()` takes a list of costs and gives back a `LunchLensResult`. Theres no flutter widgets in it so its separate from the ui and easy to unit test.

- it skips any cost thats 0 or less
- it needs 3 good purchases before it guesses
- the guess is the average of the 3 newest costs
- the baseline is just the last price you paid
- `loadLunchLens()` gets the purchases from sqlite and sends the costs to `estimateNextMeal()`
- `LunchLensCard` shows the guess with Apply and Not now and Apply only fills the cost box so nothing saves until you hit Log meal

Check AI_FEATURE.md for the test cases and how we tested it.