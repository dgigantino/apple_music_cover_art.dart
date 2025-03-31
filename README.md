# apple_music_cover_art

A Dart package to fetch music album cover art from iTunes.

## Installation

Add `apple_music_cover_art` to your `pubspec.yaml` file:

```yaml
dependencies:
  apple_music_cover_art: ^1.0.0 # Use the latest version from pub.dev
```

Then run `flutter pub get` or `dart pub get` to install the package.

## Usage

Import the package in your Dart code:

```dart
import 'package:apple_music_cover_art/apple_music_cover_art.dart';
```

Use the `CoverArtFetcher` class to search for a cover art URL:

```dart
import 'package:apple_music_cover_art/apple_music_cover_art.dart';

void main() async {
  final fetcher = CoverArtFetcher(); // Initialize the fetcher

  String artist = 'The Beatles';
  String album = 'Abbey Road';

  String? imageUrl = await fetcher.getCoverArtUrl(artist: artist, album: album);

  if (imageUrl != null) {
    print('Cover Art URL: $imageUrl');
  } else {
    print('No cover art found for $artist - $album.');
  }
}
```

**`CoverArtFetcher` Configuration Options:**

The `CoverArtFetcher` constructor accepts the following optional parameters to customize its behavior:

*   `verbose`: `bool` (default: `false`). Enables detailed logging to the console.
*   `throttle`: `double` (default: `3.0`).  Sets the delay in seconds before retrying if requests are rate-limited.
*   `artSize`: `int` (default: `500`).  Desired size of the cover art image (e.g., `500` for 500x500).
*   `artQuality`: `int` (default: `0`). Image quality setting (`0` for default, `1-100` for JPEG quality).

**Methods:**

*   `getCoverArtUrl({required String artist, String? album, String? title})`:

    Searches for cover art on iTunes based on the provided `artist` and either `album` or `title`.

    *   `artist` (required): The name of the artist.
    *   `album` (optional): The name of the album.
    *   `title` (optional): The title of the song (use if not searching by album).

    Returns a `Future<String?>` that resolves to the cover art image URL if found, or `null` if no cover art is found.

## License

[Apache License 2.0](LICENSE)