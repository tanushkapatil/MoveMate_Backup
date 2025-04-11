import 'package:flutter/material.dart';
import 'dummy_data.dart';

class BusResultsPage extends StatelessWidget {
  final String source;
  final String destination;

  const BusResultsPage({
    Key? key,
    required this.source,
    required this.destination,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> matchingBuses = [];

    for (var bus in busRoutes) {
      List<String> route = List<String>.from(bus['route']);
      if (route.contains(source) && route.contains(destination)) {
        int sourceIndex = route.indexOf(source);
        int destinationIndex = route.indexOf(destination);
        if (sourceIndex < destinationIndex) {
          matchingBuses.add(bus);
        }
      }
    }

    return Scaffold(
      backgroundColor: Color(0xFF1E1E2E),
      appBar: AppBar(
        title: Text('Available Buses'),
        backgroundColor: Color(0xFF7F56D9),
      ),
      body: matchingBuses.isEmpty
          ? Center(
              child: Text(
                'No buses found for your route!',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: matchingBuses.length,
              padding: EdgeInsets.all(16),
              itemBuilder: (context, index) {
                var bus = matchingBuses[index];
                return Card(
                  color: Color(0xFF2A2A3D),
                  elevation: 4,
                  margin: EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: Icon(Icons.directions_bus,
                        color: Colors.white, size: 32),
                    title: Text(
                      'Bus Code: ${bus['busCode']}',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    subtitle: Text(
                      'ETA: ${bus['eta']}',
                      style: TextStyle(color: Colors.white70),
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7F56D9),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                       Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BusMapScreen(
                              bus: bus,
                              source: source,
                              destination: destination,
                            ),
                          ),
                        );
                      },
                      child: const Text('View'),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildBusDetailCard(BuildContext context, Map<String, dynamic> bus,
      String source, String destination) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A3D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.directions_bus, size: 40, color: Colors.white),
          SizedBox(height: 10),
          Text(
            'Bus Code: ${bus['busCode']}',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          SizedBox(height: 6),
          Text(
            'From $source to $destination',
            style: TextStyle(fontSize: 15, color: Colors.white70),
          ),
          SizedBox(height: 6),
          Text(
            'ETA: ${bus['eta']}',
            style: TextStyle(fontSize: 14, color: Color(0xFF7F56D9)),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close),
            label: Text('Close'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF7F56D9),
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
