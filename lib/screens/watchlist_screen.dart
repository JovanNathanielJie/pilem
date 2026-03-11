import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pilem/models/movie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'detail_screen.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});
  @override
  WatchlistScreenState createState() => WatchlistScreenState();
}

class WatchlistScreenState extends State<WatchlistScreen> {
  List<Movie> _watchlistMovies = [];

  @override
  void initState() {
    super.initState();
    _loadWatchlist();
  }

  Future<void> _loadWatchlist() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<String> watchlistJson = prefs.getStringList('watchlist') ?? [];

    setState(() {
      _watchlistMovies = watchlistJson
          .map((jsonStr) => Movie.fromJson(json.decode(jsonStr)))
          .toList();
    });
  }

  Future<void> _removeFromWatchlist(int movieId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> watchlistJson = prefs.getStringList('watchlist') ?? [];
    watchlistJson.removeWhere((jsonStr) {
      final Map<String, dynamic> movieMap = json.decode(jsonStr);
      return movieMap['id'] == movieId;
    });
    await prefs.setStringList('watchlist', watchlistJson);
    _loadWatchlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Watch List')),
      body: _watchlistMovies.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada film di watchlist',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          
          : ListView.builder(
              itemCount: _watchlistMovies.length,
              itemBuilder: (context, index) {
                final Movie movie = _watchlistMovies[index];
                return ListTile(
                  
                  leading: movie.posterPath.isNotEmpty
                      ? Image.network(
                          'https://image.tmdb.org/t/p/w92${movie.posterPath}',
                          width: 50,
                          fit: BoxFit.cover,
                        )
                      : const SizedBox(
                          width: 50,
                          child: Icon(Icons.movie),
                        ),
                  
                  title: Text(movie.title),
                  
                  subtitle: Text(
                    '${movie.releaseDate} ⭐ ${movie.voteAverage}',
                  ),
                  
                  trailing: IconButton(
                    icon: const Icon(Icons.bookmark, color: Colors.blue),
                    onPressed: () {
                      _removeFromWatchlist(movie.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${movie.title} dihapus dari watchlist'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(movie: movie),
                    ),
                  ).then((_) => _loadWatchlist()),
                );
              },
            ),
    );
  }
}
