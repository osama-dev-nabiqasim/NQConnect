import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nqconnect/models/event_models/event.dart';
import 'package:nqconnect/services/event_api_service.dart';
import 'package:nqconnect/screens/events_screens/admin/event_creation_screen.dart';
import 'package:nqconnect/screens/events_screens/event_detail_screen.dart';

/// Admin/HR screen: view list of events and create new ones.
class EventManagementScreen extends StatefulWidget {
  final String token; // Admin/HR JWT
  const EventManagementScreen({Key? key, required this.token})
    : super(key: key);

  @override
  State<EventManagementScreen> createState() => _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen> {
  late Future<List<Event>> _futureEvents;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    _futureEvents = EventApiService(token: widget.token).fetchEvents();
  }

  Future<void> _refresh() async {
    setState(() => _loadEvents());
  }

  Future<void> _openCreation() async {
    final created = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventCreationScreen(token: widget.token),
      ),
    );
    if (created == true) {
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy');
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Management"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _openCreation,
            tooltip: "Create Event",
          ),
        ],
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
                child: Text("❌ Error loading events: ${snapshot.error}"),
              );
            }
            final events = snapshot.data ?? [];
            if (events.isEmpty) {
              return const Center(child: Text("No events found."));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: events.length,
              itemBuilder: (_, i) {
                final e = events[i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 3,
                  child: ListTile(
                    title: Text(
                      e.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${df.format(e.startDate)} – ${df.format(e.endDate)}\n${e.location}",
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventDetailScreen(
                            token: widget.token,
                            event: e,
                            isAdmin: true, // show stats
                          ),
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
