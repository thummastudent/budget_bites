# Budget Bites

So Budget Bites is basically a simple offline Flutter app for students to keep track of how much they spend on food. You save the places you usually eat, log what you spend there, and see how close you are to your weekly budget. It also has a smart helper called Lunch Lens that kind of guesses what your next meal at a place is gonna cost.

## Team
| Name | What they did |
|---|---|
| Deepak Thumma | database helper, meal form, dashboard, details screen with purchase logging, history screen, settings, navigation |
| Saurav Annepu | proposal, Lunch Lens helper, Lunch Lens card, Lunch Lens unit tests, docs (README, ARCHITECTURE, AI_FEATURE, AI_Usage_Log) |

## Features
- Add, edit and delete meals (name, cuisine, venue note, target price)
- Log what you spent at a meal and see the total for that place
- If you delete a meal its purchases get deleted too (it asks you to confirm first)
- Cuisine filter on the dashboard
- History screen with a filter, total spent and average per purchase
- Weekly budget slider in Settings (saved with SharedPreferences so it stays after you close the app)
- Lunch Lens smart helper that guesses your next meal cost (more in AI_FEATURE.md)
- Everything works offline, nothing goes to the cloud