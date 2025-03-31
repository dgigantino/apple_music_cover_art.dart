import 'package:apple_music_cover_art/apple_music_cover_art.dart';

void main() async {
  // Configure the CoverArtFetcher with specific options:
  final fetcher = CoverArtFetcher(
    verbose: false,      // Enable verbose logging to the console.
    throttle: 5.0,       // Set throttle to 5 seconds for retries on rate limits.
    artSize: 300,        // Request cover art at 300x300 pixels.
    artQuality: 80,      // Request JPEG quality at 80 (if applicable, might be ignored by iTunes API).
  );

  // Define the artist and album (or song title) you want to search for:
  String artistName = 'Radiohead';
  String albumName = 'OK Computer';
  // String songTitle = 'Paranoid Android'; // Example: use song title instead of album

  // Search for the cover art URL using the configured fetcher:
  String? coverArtUrl;
  try {
    print('Searching for cover art URL for artist: $artistName, album: $albumName...');
    coverArtUrl = await fetcher.getCoverArtUrl(artist: artistName, album: albumName);
    // If searching by song title instead of album, use:
    // coverArtUrl = await fetcher.getCoverArtUrl(artist: artistName, title: songTitle);

    if (coverArtUrl != null) {
      print('Cover art URL found:');
      print(coverArtUrl); // Print the found URL to the console.
    } else {
      print('No cover art URL found for artist: $artistName, album: $albumName.');
      // Or for song title:
      // print('No cover art URL found for artist: $artistName, title: $songTitle.');
    }
  } catch (e) {
    print('Error occurred while fetching cover art URL: $e');
  }
}