# Crypto Tracker

A modern Flutter application for tracking cryptocurrency transactions and monitoring portfolio performance.

## 🚀 Features

-   **Transaction Tracking**: Easily record buy and sell transactions (BTC, ETH, etc.).
-   **Portfolio Dashboard**: Real-time overview of your holdings and total portfolio value.
-   **Currency Support**: Native support for **EUR** as the primary currency.
-   **Import**: Bulk import transactions from Excel files.
-   **Cloud Sync**: All data is securely stored and synced via Cloud Firestore.

## 🛠 Tech Stack

-   **Framework**: [Flutter](https://flutter.dev)
-   **Backend**: [Firebase](https://firebase.google.com) (Auth, Firestore)
-   **State Management**: Streaming via [BehaviorSubject](https://pub.dev/packages/rxdart)
-   **Dependency Injection**: [GetIt](https://pub.dev/packages/get_it)
-   **Architecture**: Feature-based modular structure.

## 📦 Getting Started

### Prerequisites

-   [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.9.2)
-   [Firebase CLI](https://firebase.google.com/docs/cli) (for backend configuration)

### Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/betusin/crypto-tracker.git
    cd crypto-tracker
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Firebase Setup**:
    -   Create a new Firebase project in the [Firebase Console](https://console.firebase.google.com/).
    -   Run `flutterfire configure` to set up your project locally.
    -   Enable Google Sign-In and Cloud Firestore in the console.

4.  **Run the app**:
    ```bash
    flutter run
    ```

## 🏗 Project Structure

The project follows a feature-based organization to maintain scalability:

```text
lib/
├── auth/               # Authentication logic and screens
├── portfolio/          # Dashboard and holdings summary
├── transaction/        # Transaction CRUD operations
├── transaction_import/ # Excel import functionality
├── common/             # Shared widgets and utilities
├── database/           # Firestore service layer
├── currency/           # Currency formatting and conversion
├── ioc/                # Dependency injection setup
└── main.dart           # Application entry point
```

## 📄 License

This project is for private use only.
