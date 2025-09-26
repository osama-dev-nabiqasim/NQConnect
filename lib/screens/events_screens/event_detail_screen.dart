import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nqconnect/models/event_models/event.dart';
import 'package:nqconnect/models/event_models/event_stats.dart';
import 'package:nqconnect/services/event_api_service.dart';

/// Displays detailed info of an event.
/// Employees can RSVP, Admin/HR can also view stats.
class EventDetailScreen extends StatefulWidget {
  final String token;
  final Event event;
  final bool isAdmin;
  const EventDetailScreen({
    Key? key,
    required this.token,
    required this.event,
    this.isAdmin = false,
  }) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _loadingRsvp = false;
  EventStats? _stats;

  @override
  void initState() {
    super.initState();
    if (widget.isAdmin) _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final stats = await EventApiService(
        token: widget.token,
      ).fetchEventStats(widget.event.eventId);
      setState(() => _stats = stats);
    } catch (e) {
      debugPrint("❌ Stats fetch failed: $e");
    }
  }

  Future<void> _rsvp(int type) async {
    setState(() => _loadingRsvp = true);
    try {
      await EventApiService(
        token: widget.token,
      ).rsvpEvent(eventId: widget.event.eventId, responseType: type);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ RSVP saved")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ RSVP failed: $e")));
    } finally {
      if (mounted) setState(() => _loadingRsvp = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final df = DateFormat('dd MMM yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(title: Text(e.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              e.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(e.description),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.schedule, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${df.format(e.startDate)} – ${df.format(e.endDate)}",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.place, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(e.location)),
              ],
            ),
            const SizedBox(height: 8),
            Text("Category: ${e.category}"),
            const SizedBox(height: 8),
            Text("Max Capacity: ${e.maxCapacity}"),
            const SizedBox(height: 8),
            Text(
              "RSVP Deadline: "
              "${e.rsvpDeadline != null ? df.format(e.rsvpDeadline!) : 'No deadline'}",
            ),

            const SizedBox(height: 24),

            // --- RSVP Buttons ---
            if (!_loadingRsvp)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text("Going"),
                    onPressed: () => _rsvp(1),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text("Not Going"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => _rsvp(2),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.help_outline),
                    label: const Text("Maybe"),
                    onPressed: () => _rsvp(3),
                  ),
                ],
              )
            else
              const Center(child: CircularProgressIndicator()),

            const SizedBox(height: 24),

            // --- Admin Stats ---
            if (widget.isAdmin && _stats != null) ...[
              const Divider(),
              const Text(
                "Event Statistics",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("✅ Going: ${_stats!.goingCount}"),
              Text("❌ Not Going: ${_stats!.notGoingCount}"),
              Text("🤔 Maybe: ${_stats!.maybeCount}"),
              Text("Total Responses: ${_stats!.totalResponded}"),
            ],
          ],
        ),
      ),
    );
  }
}
