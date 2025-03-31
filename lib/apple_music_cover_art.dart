import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'normalizer.dart';
import 'deromanizer.dart';

class _AppleDownloader {
  static const String queryTemplate =
      "https://itunes.apple.com/search?term=%s&media=music&entity=%s";

  final bool verbose;
  final double throttle;
  final int artSize;
  final int artQuality;
  final ArtistNormalizer artistNormalizer;
  final AlbumNormalizer albumNormalizer;
  final DeRomanizer deromanizer;

  _AppleDownloader({
    required this.verbose,
    required this.throttle,
    required this.artSize,
    required this.artQuality,
    required this.artistNormalizer,
    required this.albumNormalizer,
    required this.deromanizer,
  });

  Future<String?> searchCoverArtUrl(String artist, String? album, String? title) async {
    final info = await _query(artist, album, title);

    if (info != null && info['resultCount'] > 0) {
      try {
        String? imageUrl;

        List<dynamic> results = List.from(info['results'].reversed);

        if (album == null || album.isEmpty) {
          results.sort((a, b) => a['releaseDate'].compareTo(b['releaseDate']));
        }

        for (var albumInfo in results) {
          final String foundArtist =
              artistNormalizer.normalize(albumInfo['artistName']);
          final String foundAlbum =
              albumNormalizer.normalize(albumInfo['collectionName']);

          if (!foundArtist.contains(artistNormalizer.normalize(artist))) {
            continue;
          }

          if ((album != null && album.isNotEmpty) &&
              !foundAlbum.contains(albumNormalizer.normalize(album))) {
            continue;
          }

          imageUrl = albumInfo['artworkUrl100']
              .replaceAll('100x100bb', '${artSize}x${artSize}bb');

          if ((album != null && album.isNotEmpty) &&
              foundAlbum == albumNormalizer.normalize(album)) {
            break; // exact match
          }
        }
        return imageUrl;
      } catch (e) {
        print('Error parsing search results: $e');
      }
    }

    if (verbose) {
      print('No results found for $artist - $album');
    }
    return null;
  }

  Future<void> downloadCoverArt(String imageUrl, String destPath) async {
    final response = await _makeRequest(imageUrl);

    if (response.statusCode == 200) {
      final file = File(destPath);
      await file.writeAsBytes(response.bodyBytes);
      if (verbose) {
        print('Downloaded image to: $destPath');
      }
    } else {
      throw Exception(
          'Failed to download image. Status code: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>?> _query(
      String artist, String? album, String? title) async {
    final token = album ?? title;
    final entity = album != null ? 'album' : 'musicTrack';

    String queryTerm = '$artist $token';

    // If token is empty or is the same as artist, just use artist
    if (token == null || token.isEmpty || token == artist) {
      queryTerm = artist;
    }

    String url = Uri.encodeFull(sprintf(queryTemplate, [queryTerm, entity]));

    if (verbose) {
      print('Query URL: $url');
    }

    final response = await _makeRequest(url);

    if (verbose) {
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }

    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        print('Error decoding JSON: $e');
      }
    } else {
      print('Error: ${response.statusCode}');
    }
    return null;
  }

  Future<http.Response> _makeRequest(String url) async {
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (verbose) {
      print('Request URL: $url');
      print('Request headers: ${response.request?.headers}');
      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');
    }

    if (response.statusCode == 403 || response.statusCode == 429) {
      // Throttled
      final domain = uri.host;
      print(
          'WARNING: Request limit exceeded from $domain, trying again in $throttle seconds...');
      await Future.delayed(Duration(seconds: throttle.toInt()));
      return _makeRequest(url); // Retry
    } else if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }
}

String sprintf(String template, List<dynamic> arguments) {
  for (var argument in arguments) {
    template = template.replaceFirst('%s', argument.toString());
  }
  return template;
}

/// Fetches cover art from iTunes.
class CoverArtFetcher {
  final bool verbose;
  final double throttle;
  final int artSize;
  final int artQuality;
  final ArtistNormalizer artistNormalizer;
  final AlbumNormalizer albumNormalizer;
  final DeRomanizer deromanizer;

  CoverArtFetcher({
    this.verbose = false,
    this.throttle = 3.0,
    this.artSize = 500,
    this.artQuality = 0,
    ArtistNormalizer? artistNormalizer,
    AlbumNormalizer? albumNormalizer,
    DeRomanizer? deromanizer,
  })  : artistNormalizer = artistNormalizer ?? ArtistNormalizer(),
        albumNormalizer = albumNormalizer ?? AlbumNormalizer(),
        deromanizer = deromanizer ?? DeRomanizer();

  /// Searches for cover art URL on iTunes based on artist, album, or title.
  ///
  /// Provide artist and either album or title to search.
  /// Returns the URL of the cover art image if found, otherwise null.
  Future<String?> getCoverArtUrl({required String artist, String? album, String? title}) async {
    final downloader = _AppleDownloader(
      verbose: verbose,
      throttle: throttle,
      artSize: artSize,
      artQuality: artQuality,
      artistNormalizer: artistNormalizer,
      albumNormalizer: albumNormalizer,
      deromanizer: deromanizer,
    );
    return downloader.searchCoverArtUrl(artist, album, title);
  }

  /// Downloads cover art from the given URL and saves it to the specified destination path.
  ///
  /// [imageUrl] is the URL of the cover art image.
  /// [destPath] is the path where the image will be saved.
  Future<void> downloadCoverArt({required String imageUrl, required String destPath}) async {
    await _AppleDownloader(
        verbose: verbose,
        throttle: throttle,
        artSize: artSize,
        artQuality: artQuality,
        artistNormalizer: artistNormalizer,
        albumNormalizer: albumNormalizer,
        deromanizer: deromanizer
    ).downloadCoverArt(imageUrl, destPath);
  }
}