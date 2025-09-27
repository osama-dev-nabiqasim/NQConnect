import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nqconnect/models/event_models/event.dart';
import 'package:nqconnect/services/event_api_service.dart';
import 'package:nqconnect/screens/events_screens/event_detail_screen.dart';
import 'package:nqconnect/utils/responsive.dart';

/// Screen for employees and admins to view upcoming events
/// and tap to see detail / respond.
class EventListScreen extends StatefulWidget {
  final String token;
  const EventListScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  late Future<List<Event>> _futureEvents;

  @override
  void initState() {
    super.initState();
    _futureEvents = EventApiService().fetchEvents(); // ✅
  }

  Future<void> _refresh() async {
    setState(() {
      _futureEvents = EventApiService().fetchEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy');
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upcoming Events"),
        backgroundColor: AppColors.appbarColor.first,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Event>>(
          future: _futureEvents,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text("Error loading events: ${snapshot.error}"),
              );
            }
            final events = snapshot.data ?? [];
            if (events.isEmpty) {
              return const Center(child: Text("No upcoming events."));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: events.length,
              itemBuilder: (context, i) {
                final e = events[i];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(
                      e.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${df.format(e.startDate)} - ${df.format(e.endDate)}\n${e.location}",
                    ),
                    isThreeLine: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EventDetailScreen(token: widget.token, event: e),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
