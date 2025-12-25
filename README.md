# Synchronized Scroll Mobile UI

A beautifully crafted Flutter application that demonstrates advanced scrolling synchronization between multiple content views. This app features a sticky app bar with a scrollable content area containing two perfectly synchronized views - a vertical circle list and a grid layout that scroll in harmony.

## ✨ Features

- **Synchronized Scrolling**: Both the circle list and grid view scroll together seamlessly
- **Sticky App Bar**: Navigation remains fixed while content scrolls underneath
- **Smooth Pagination**: Content loads automatically as you scroll, maintaining your position
- **Material Design 3**: Modern, beautiful UI following Google's latest design guidelines
- **Responsive Layout**: Adapts perfectly to different screen sizes
- **Accessibility**: Built with screen readers and accessibility guidelines in mind

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (version 3.0 or higher)
- Dart SDK (version 2.19 or higher)
- Android Studio or VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/synchronized_scroll_mobile_ui.git
   cd synchronized_scroll_mobile_ui
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📱 How It Works

This app showcases an innovative approach to synchronized scrolling:

- **Global Scroll Controller**: A single controller manages the entire scrollable area
- **Gesture Forwarding**: Scroll gestures from either view (circle list or grid) control the global scroll
- **Smart Pagination**: Content loads automatically at 80% scroll threshold
- **Position Preservation**: Your scroll position is maintained when new content loads

## 🏗️ Architecture

The app is built with a clean, maintainable architecture:

- **Constants**: Centralized color, dimension, spacing, and string constants
- **Themes**: Consistent typography and theme definitions using Plus Jakarta Sans
- **Widgets**: Modular, reusable components for maximum maintainability
- **Screens**: Clean separation of concerns with dedicated screen widgets

## 🛠️ Built With

- **Flutter**: UI toolkit for building natively compiled applications
- **Material Design 3**: Google's latest design system
- **Plus Jakarta Sans**: Modern, readable typography
- **Google Fonts**: Beautiful, consistent font rendering

## 📚 Documentation

For detailed technical documentation including:
- Scroll synchronization implementation
- Pagination strategy
- Performance considerations
- Architecture decisions

See [docs/SCROLL_SYNC_README.md](docs/SCROLL_SYNC_README.md)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋‍♂️ Support

If you have any questions or need help, please open an issue on GitHub.

---

**Enjoy exploring synchronized scrolling! 🎉**
