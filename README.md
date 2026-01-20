# Live Age Menu Bar

A macOS menu bar app that displays your live age in real-time with 5 decimal places of precision.

![Live Age Menu Bar Screenshot](screenshot.png)

## Features

- **Real-time age display** - Shows your age updating continuously in the menu bar
- **Detailed breakdown** - View your age in years, months, days, hours, minutes, and seconds
- **Customizable birthday** - Set your own birthday via the date picker
- **Launch at Login** - Option to start automatically when you log in
- **Lightweight** - Minimal CPU usage with optimized rendering

## Installation

### Download

Download the latest release from the [Releases](https://github.com/FernandoTN/live-age-menubar/releases) page.

### Build from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/FernandoTN/live-age-menubar.git
   ```
2. Open `MenuBarAgeCounter.xcodeproj` in Xcode
3. Build and run (Cmd+R)

## Usage

On first launch, you'll be prompted to set your birthday. You can change it anytime from the menu.

| Menu Item | Description |
|-----------|-------------|
| Age breakdown | Shows years, months, days, hours, minutes, seconds |
| Born: [date] | Displays your configured birthday |
| Set Birthday... | Opens the date picker (Cmd+B) |
| Launch at Login | Toggle automatic startup |
| Quit | Exit the application (Cmd+Q) |

## Requirements

- macOS 13.0 or later

## Privacy

All data is stored locally on your device using UserDefaults. No data is transmitted to any servers.

## License

MIT License - see [LICENSE](LICENSE) for details.
