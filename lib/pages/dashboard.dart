import 'package:flutter/material.dart';
import '../database/albumstore.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  final AlbumDatabase _albumDatabase = AlbumDatabase();

  Widget _buildStatistic(String label, Future<int> Function() fetchData){
    return FutureBuilder<int>(
      future: fetchData(),
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          );
        }else if(snapshot.hasError){
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Error: ${snapshot.error}'),
          );
        }else{
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('$label: ${snapshot.data}'),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            _buildStatistic('My All Songs', () => _albumDatabase.countUserSongs()),
            _buildStatistic('My All Albums', () => _albumDatabase.countUserAlbums()),
            _buildStatistic('Public All Songs', () => _albumDatabase.countAllSongs()),
            _buildStatistic('Public All Albums', () => _albumDatabase.countAllAlbums()),
          ],
        ),
      ),
    );
  }
}
