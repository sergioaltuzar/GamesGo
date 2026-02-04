# GamesGo

A free-to-play video game catalog app for iOS built with SwiftUI and SwiftData. The app downloads game data from the [FreeToGame API](https://www.freetogame.com/api-doc), stores it locally, and provides browsing, searching, filtering, and personal note-taking features — all with zero third-party dependencies.

## Screenshots

<table style="width: 100%; border-collapse: collapse; border: none;">
  <tr>
    <td align="center" style="width: 32%; border: none;">
      <img src="https://github.com/user-attachments/assets/a9dd91a5-4a2a-45c3-abb9-9d0404291479" alt="Screenshot 1" style="width: 100%;">
    </td>
    <td align="center" style="width: 32%; border: none;">
      <img src="https://github.com/user-attachments/assets/67a0d3eb-c295-450d-ac2c-3a884d290946" alt="Screenshot 2" style="width: 100%;">
    </td>
    <td align="center" style="width: 32%; border: none;">
      <img src="https://github.com/user-attachments/assets/46873cae-708b-4e63-bc18-bcb5412eacbd" alt="Screenshot 3" style="width: 100%;">
    </td>
  </tr>
</table>


The app features a dark futuristic UI with three main screens:

1. **Loading Screen** — Animated gradient with dual spinning rings and a pulsing glow effect.
2. **Game Library** — Searchable, filterable catalog with genre chips and glass-style cards.
3. **Game Detail** — Hero image, game metadata, editable user notes, and soft-delete functionality.

## Technical Decisions

### 1. Architecture: MVVM

The app follows the **Model-View-ViewModel** pattern with clear separation of concerns:

```
GamesGo/
├── Models/              # Data layer (Game, GameDTO, Genre)
├── Services/            # Network + persistence (NetworkService, GameRepository)
├── ViewModels/          # Business logic (@Observable ViewModels)
├── Views/               # SwiftUI screens
│   └── Components/      # Reusable UI components
└── Utilities/           # ImageCache, Constants
```

- **Models** define the data structures (`Game` as a SwiftData `@Model`, `GameDTO` as a `Codable` transfer object).
- **ViewModels** (`LoadingViewModel`, `GameCatalogViewModel`, `GameDetailViewModel`) use `@Observable` (not `ObservableObject`) and contain all business logic, keeping Views declarative and free of logic.
- **Views** only handle presentation and user interaction, delegating all state mutations to their ViewModel.

### 2. Design Patterns: SOLID Principles

- **Single Responsibility**: Each class has one clear purpose. `NetworkService` handles HTTP requests, `GameRepository` handles persistence, ViewModels handle presentation logic, and Views handle rendering.
- **Open/Closed**: The `NetworkServiceProtocol` allows extending network behavior (e.g., swapping implementations for testing) without modifying existing code.
- **Liskov Substitution**: `MockNetworkService` conforms to `NetworkServiceProtocol` and is fully interchangeable with `NetworkService` in tests.
- **Interface Segregation**: `NetworkServiceProtocol` exposes only `fetchGames()` — consumers don't depend on methods they don't use.
- **Dependency Inversion**: ViewModels depend on the `NetworkServiceProtocol` abstraction, not the concrete `NetworkService`. `GameRepository` is injected into ViewModels, and `URLSession` is injected into `NetworkService`, enabling full testability.

### 3. Development Logic: Clarity, Efficiency, and Readability

- **async/await** is used exclusively for concurrency — no GCD (`DispatchQueue`) or completion handlers anywhere in the codebase.
- **Computed properties** (`filteredGames`, `genres`, `suggestions`) in `GameCatalogViewModel` provide reactive filtering without redundant state.
- **DTO-to-Model mapping** (`GameDTO.toGame()`) keeps the API layer decoupled from the persistence layer. API field changes only require updating the DTO, not the SwiftData model.
- **Soft delete** (`isRemoved` flag) instead of hard delete preserves data integrity and allows catalog reload to restore removed games while keeping user notes intact.
- **Upsert logic** in `GameRepository.insertGames()` checks for existing records by `apiId` before inserting. Existing games get their API fields updated but `userNotes` are preserved.

### 4. SwiftUI: Components, Responsive Design, and Accessibility

- **`@Observable` macro** (iOS 17+) is used instead of `ObservableObject`/`@Published` for simpler, more granular observation.
- **`NavigationStack`** with type-safe `navigationDestination(for: PersistentIdentifier.self)` for navigation.
- **Reusable components**: `GameCardView`, `GenreChipView`, `SearchBarView`, `AsyncGameImage`, and `GlassBackground` (ViewModifier) are self-contained and composable.
- **`FlowLayout`** (custom `Layout` protocol implementation) handles wrapping genre/platform tags without horizontal overflow.
- **`GeometryReader`** constrains the hero image width within `ScrollView` to prevent content overflow.
- **`.scrollDismissesKeyboard(.immediately)`** and tap-to-dismiss gestures ensure the keyboard never obstructs the UI.
- **Dark mode** is enforced via `.preferredColorScheme(.dark)` for visual consistency.

### 5. API Consumption: HTTP Requests and Error Handling

- **`NetworkService`** uses `URLSession` with `async/await` to fetch from `GET https://www.freetogame.com/api/games`.
- **Injectable `URLSession`** (`init(session: URLSession = .shared)`) allows substituting a custom session with `MockURLProtocol` in tests.
- **`NetworkError`** enum conforms to `LocalizedError` with three cases: `invalidURL`, `badResponse`, `decodingFailed` — each providing a user-readable `errorDescription`.
- **HTTP status validation** checks for `200...299` range before attempting JSON decoding.
- **`GameDTO`** uses `CodingKeys` to map snake_case API fields (`short_description`, `game_url`, `release_date`, `freetogame_profile_url`) to camelCase Swift properties.
- **Error propagation**: Network errors bubble up through the ViewModel to the View, where a retry button is displayed.

### 6. Data Persistence: Local Storage with SwiftData

- **SwiftData** (`@Model`) is used as the persistence layer with automatic schema management.
- **`Game` model** includes a `#Unique<Game>([\.apiId])` constraint to prevent duplicate entries.
- **`GameRepository`** provides a clean CRUD interface: `hasGames()`, `insertGames(_:)`, `allActiveGames()`, `softDelete(_:)`, and `saveChanges()`.
- **Filtered queries** use `#Predicate<Game> { $0.isRemoved == false }` with `SortDescriptor(\.title)` for sorted, active-only results.
- **User data preservation**: The reload flow re-downloads the full catalog from the API but performs an upsert — existing games keep their `userNotes` intact; only removed games get their `isRemoved` flag reset to `false`.
- **In-memory containers** (`ModelConfiguration(isStoredInMemoryOnly: true)`) are used in tests to avoid disk I/O and test isolation issues.

### 7. UX: Usability, Visual Consistency, and Navigation

- **Three-screen flow**: Loading → Game Library → Game Detail, with a root coordinator (`ContentView`) toggling between loading and catalog states.
- **Animated loading screen**: Dual spinning rings with gradient stroke, pulsing radial glow, gamecontroller icon, and animated ellipsis text. A minimum 3-second display ensures the animation is visible even on fast connections.
- **Glass morphism design**: `.ultraThinMaterial` backgrounds with subtle white border strokes create a consistent frosted-glass aesthetic across all cards, the search bar, and the detail panel.
- **Genre filtering**: Horizontal scroll of pill-shaped chips derived dynamically from the data (not hardcoded), with an "All" option.
- **Search with suggestions**: Real-time text filtering by title and genre, with a suggestions dropdown showing up to 5 matching titles.
- **Catalog reload**: A toolbar button re-downloads the full catalog, restoring soft-deleted games while preserving user notes on active games.
- **Navigation state management**: `NavigationPath` is tracked to reload the game list when returning from detail (ensuring deleted games disappear immediately).
- **Keyboard handling**: Keyboard dismisses on scroll (`.scrollDismissesKeyboard(.immediately)`) and on tap outside text fields.
- **Auto-save**: User notes are saved automatically via `.onDisappear` on the detail screen.
- **Soft delete with confirmation**: A `confirmationDialog` prevents accidental deletions.

### 8. Unit Tests: Quality, Coverage, and Structure

The test suite contains **47 tests** across 6 test files using the **Swift Testing** framework (`@Test`, `#expect`, `@Suite`):

| Test File | Tests | What It Covers |
|---|---|---|
| `GamesGoTests.swift` | 8 | `GameRepository` CRUD: insert, fetch, soft delete (single + targeted), sorted results, save changes, empty array handling |
| `GameDTOTests.swift` | 8 | JSON decoding (valid, empty, invalid, missing fields, snake_case keys), `toGame()` field mapping, default values |
| `NetworkServiceTests.swift` | 10 | Real `NetworkService` with `MockURLProtocol` (success, 500 error, 404 error, invalid JSON, empty array), mock service behavior, error descriptions, `LocalizedError` conformance |
| `LoadingViewModelTests.swift` | 6 | `needsDownload` states, download success/failure, retry resets error, initial state |
| `GameCatalogViewModelTests.swift` | 8 | Genre filtering, text search, combined filters, genre list generation, "All" genre, suggestions (matching + empty), search by genre name |
| `GameDetailViewModelTests.swift` | 7 | Save notes, delete game, initial state, empty notes, delete + notes interaction, deleted game exclusion from active list |

## Screenshots
<table style="width: 100%; border-collapse: collapse; border: none;">
  <tr>
    <td align="center" valign="top" style="width: 48%; border: none;">
  <img src="https://github.com/user-attachments/assets/37df426b-d5a5-43fc-b66f-7b012313bc6d" alt="Captura 2" style="width: 100%;">    
    </td>
    <td align="center" valign="top" style="width: 48%; border: none;">
      <img src="https://github.com/user-attachments/assets/66e25b40-5155-4f78-bdab-310958956bf5" alt="Captura 1" style="width: 100%;">
    </td>
  </tr>
</table>

**Testing patterns used:**

- **Protocol-based mocking**: `MockNetworkService` conforms to `NetworkServiceProtocol` for ViewModel tests.
- **`MockURLProtocol`**: Intercepts real `URLSession` requests to test `NetworkService` without network access.
- **In-memory SwiftData containers**: Each test creates an isolated `ModelContainer` with `UUID().uuidString` names to prevent cross-test contamination.
- **`@Suite(.serialized)`**: Ensures SwiftData tests run sequentially to avoid concurrent access crashes.
- **`withExtendedLifetime(container) {}`**: Keeps `ModelContainer` alive for the duration of each test, preventing premature deallocation.

## Requirements

- iOS 18.0+
- Xcode 16.0+
- Swift 6.0+
- No third-party dependencies

## How to Run

1. Clone the repository
2. Open `GamesGo.xcodeproj` in Xcode
3. Select an iOS 18+ simulator
4. Press `Cmd + R` to build and run

## How to Test

Run all unit tests with `Cmd + U` in Xcode, or from the terminal:

```bash
xcodebuild test -scheme GamesGo -destination 'platform=iOS Simulator,name=iPhone 16'
```

## API

The app consumes the [FreeToGame API](https://www.freetogame.com/api-doc):

```
GET https://www.freetogame.com/api/games
```

Returns an array of free-to-play games with fields: `id`, `title`, `thumbnail`, `short_description`, `game_url`, `genre`, `platform`, `publisher`, `developer`, `release_date`, `freetogame_profile_url`.
