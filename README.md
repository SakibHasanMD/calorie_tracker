# 🍽️ Calorie Tracker

*A simple, fast, and offline-first calorie tracking application built with Flutter.*

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![SQLite](https://img.shields.io/badge/SQLite-Local%20Database-003B57?logo=sqlite)
![Platform](https://img.shields.io/badge/Platform-Android-success)
![License](https://img.shields.io/badge/License-MIT-green)


---

## 📖 About

**Calorie Tracker** is a lightweight Flutter application designed to help quickly log daily calorie intake.

This project started with the help of Claude Sonnet 5 because I wanted a simple calorie tracker for my own use.

Most calorie tracking apps either require a subscription, force you to create an account, or depend on an internet connection. I didn't need all of that—I just wanted something lightweight, fast, and private.

With that goal in mind, this project focuses on simplicity, speed, and offline usage. All data is stored locally using SQLite, so the app works entirely offline while keeping your data private and the experience responsive.

This repository currently contains **Version 0 (MVP)**,I've used foods items that I eat on a daily basis. A lot of thhings need improvement. I plan to create a proper project with advanced feature later on.


# ✨ Features

### Version 0 (Current — MVP)

| Feature | Description |
|---------|-------------|
| **Home** | View today's total calories and a list of all foods logged today |
| **Add Food** | Pick from 56 built-in foods, enter weight/pieces, and see live calorie calculation |
| **History** | Browse every day that has entries. Tap a day to see all meals eaten |
| **Day Detail** | Full breakdown of meals for any selected day with per-item delete |
| **Statistics** | Simple summaries: Today, This Week, This Month, All Time, 7-day & 30-day averages |
| **Offline** | Everything runs locally — no internet required |
| **Persistent** | All data stored in SQLite — survives app restarts |


# 🛠 Tech Stack

**Tech Stack:** Flutter · Dart · SQLite (sqflite) · Material 3 · 


# 📂 Project Structure

```text
lib/

├── database/
│   └── db_helper.dart
│
├── models/
│   ├── food.dart
│   └── meal.dart
│
├── screens/
│   ├── add_food_screen.dart
│   ├── day_detail_screen.dart
│   ├── history_screen.dart
│   ├── home_screen.dart
│   └── statistics_screen.dart
│
├── services/
│   └── calorie_service.dart
│
├── widgets/
│   └── meal_card.dart
│
└── main.dart
```


# 📸 Screens

> Screenshots will be added as development progresses.

| Home | Add Food | History | Statistics |
|------|----------|----------|------------|
| 🚧 | 🚧 | 🚧 | 🚧 |



# 📋 Roadmap

## ✅ Version 0 (Current MVP)

- [x] Offline calorie tracking
- [x] Local SQLite database
- [x] Food search
- [x] Meal history
- [x] Basic statistics

---

## 🔜 Version 1

- [ ] coming soon....
- [ ] coming soon....
- [ ] coming soon....
- [ ] coming soon....
- [ ] coming soon....


---



## 🙏 Acknowledgments

- Calorie data sourced from standard nutritional references
- Built as a personal project to track my daily calories.

---