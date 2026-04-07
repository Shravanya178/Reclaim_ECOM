
# ReClaim

ReClaim is a campus sustainability and resource-sharing app built with Flutter. It empowers students, labs, and administrators to discover, share, and track the reuse of materials, reducing waste and promoting a circular economy within educational institutions.

## Features

- **Multi-Role Dashboards:**
	- Student, Lab, and Admin dashboards with tailored quick actions and navigation.
- **Campus & Department Selection:**
	- Onboarding flow to select your institution and department.
- **Discovery Map:**
	- Find available materials and resources on an interactive campus map.
- **Skill Barter:**
	- Exchange skills for materials in a dedicated marketplace.
- **Impact Dashboard:**
	- Track environmental impact, CO₂ saved, and leaderboard rankings.
- **Material Lifecycle Tracking:**
	- Monitor the journey and reuse of materials across campus.
- **Admin Tools:**
	- Manage materials, users, and campus zones with quick actions.
- **Responsive UI:**
	- Mobile-first design with adaptive layouts and overflow protection.

## Screenshots

> Add screenshots of the onboarding, dashboard, discovery map, and impact dashboard here.

## Getting Started

### Prerequisites
- [Flutter](https://flutter.dev/docs/get-started/install) (3.10.0 or later recommended)
- Dart SDK
- Android Studio or VS Code
- A device or emulator

### Installation
1. **Clone the repository:**
	 ```sh
	 git clone https://github.com/Shravanya178/HackNova_ReClaim.git
	 cd HackNova_ReClaim
	 ```
2. **Install dependencies:**
	 ```sh
	 flutter pub get
	 ```
3. **Run the app:**
	 ```sh
	 flutter run -d <device_id>
	 ```
	 Replace `<device_id>` with your emulator or device ID (e.g., `flutter devices`).

### Building APK
```sh
flutter build apk --debug
```

## Project Structure

- `lib/features/auth/` — Onboarding, login, and campus selection
- `lib/features/dashboard/` — Student, Lab, and Admin dashboards
- `lib/features/opportunities/` — Skill barter and material requests
- `lib/features/impact/` — Impact dashboard and lifecycle tracking
- `lib/core/` — Shared services, widgets, and utilities

## Tech Stack
- **Flutter** (Material 3, go_router, flutter_map, screenutil)
- **Supabase** (backend, real-time data)
- **Dart**

## Contributing
Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## License
[MIT](LICENSE)

---

*Made with ❤️ for campus sustainability.*
