import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nqconnect/models/event_models/event.dart';
import 'package:nqconnect/models/event_models/event_stats.dart';
import 'package:nqconnect/services/event_api_service.dart';
import 'package:nqconnect/utils/responsive.dart';

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
  int _userRsvpStatus = 0;
  // 2. Response change karne ke liye comment box ka data
  final TextEditingController _commentController = TextEditingController();
  // 3. Comment box aur final submit button show karne ke liye
  int _pendingRsvpType = 0; // 0=None, 1=Going, 2=Not Going, 3=Maybe

  @override
  void initState() {
    super.initState();
    if (widget.isAdmin) _fetchStats();
    // 🚀 Naya function call: User ka RSVP status load karein
    _loadUserRsvp();
  }

  Future<void> _loadUserRsvp() async {
    setState(() => _loadingRsvp = true);
    try {
      final status = await EventApiService().fetchUserRsvpStatus(
        widget.event.eventId.toString(),
      );
      if (!mounted) return;
      setState(() {
        _userRsvpStatus =
            status; // Status ko state mein save karein (0, 1, 2, ya 3)
      });
    } catch (e) {
      debugPrint("❌ User RSVP Status fetch failed: $e");
      // Agar fetch fail ho, toh status 0 hi rehne dein
    } finally {
      if (mounted) setState(() => _loadingRsvp = false);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // 🚀 Naya function: RSVP process shuru karne ke liye (comment box dikhane ke liye)
  void _startRsvpProcess(int type) {
    if (type == 1) {
      // Going choose kiya toh seedha submit
      _rsvp(type, null);
    } else {
      // Not Going ya Maybe choose kiya toh comment box show karo
      setState(() {
        _pendingRsvpType = type;
      });
    }
  }

  Future<void> _fetchStats() async {
    try {
      final stats = await EventApiService().fetchEventStats(
        widget.event.eventId,
      );
      setState(() => _stats = stats);
    } catch (e) {
      debugPrint("❌ Stats fetch failed: $e");
    }
  }

  // Future<void> _rsvp(int type) async {
  //   setState(() => _loadingRsvp = true);
  //   try {
  //     await EventApiService().rsvpEvent(
  //       eventId: widget.event.eventId,
  //       responseType: type,
  //     );
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text("✅ RSVP saved")));
  //   } catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text("❌ RSVP failed: $e")));
  //   } finally {
  //     if (mounted) setState(() => _loadingRsvp = false);
  //   }
  // }

  // 🚀 Updated RSVP function (ab comment bhi leta hai)
  Future<void> _rsvp(int type, String? comment) async {
    setState(() {
      _loadingRsvp = true;
      _pendingRsvpType = 0; // Hide comment box after starting submission
    });

    try {
      await EventApiService().rsvpEvent(
        eventId: widget.event.eventId,
        responseType: type,
        comment: comment, // API service mein comment parameter add karna padega
      );
      if (!mounted) return;
      setState(() {
        _userRsvpStatus = type; // Save the new status
        // Comment box ka content clear kar dein
        _commentController.clear();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ RSVP saved")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ RSVP failed: $e")));
      // Agar fail ho toh buttons wapis show ho jayen
      setState(() {
        _userRsvpStatus = 0;
      });
    } finally {
      if (mounted) setState(() => _loadingRsvp = false);
    }
  }

  void _updateRsvp() {
    setState(() {
      _userRsvpStatus = 0; // Reset status taaki buttons wapis show ho jayen
    });
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final df = DateFormat('dd MMM yyyy');
    return Scaffold(
      appBar: AppBar(
        title: Text(e.title),
        backgroundColor: AppColors.appbarColor.first,
      ),
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
            // if (widget.isAdmin) ...[
            //   // Admin ko sirf stats dikhenge, RSVP buttons nahi
            //   const Text("Admin View: RSVP buttons are hidden."),
            //   const SizedBox(height: 16),
            // ] else if (!_loadingRsvp)
            //   Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceAround,
            //     children: [
            //       ElevatedButton.icon(
            //         icon: const Icon(Icons.check),
            //         label: const Text("Going"),
            //         onPressed: () => _rsvp(1),
            //       ),
            //       ElevatedButton.icon(
            //         icon: const Icon(Icons.close),
            //         label: const Text("Not Going"),
            //         style: ElevatedButton.styleFrom(
            //           backgroundColor: Colors.red,
            //         ),
            //         onPressed: () => _rsvp(2),
            //       ),
            //       ElevatedButton.icon(
            //         icon: const Icon(Icons.help_outline),
            //         label: const Text("Maybe"),
            //         onPressed: () => _rsvp(3),
            //       ),
            //     ],
            //   )
            // else
            //   const Center(child: CircularProgressIndicator()),
            if (widget.isAdmin) ...[
              // Admin ko sirf stats dikhenge, RSVP buttons nahi
              // const Text("Admin View: RSVP buttons are hidden."),
              // const SizedBox(height: 16),
            ] else if (_loadingRsvp) ...[
              const Center(child: CircularProgressIndicator()),
            ] else if (_userRsvpStatus != 0) ...[
              // 🚀 Already responded, show status and Update button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          // Light color for a soft, elevated look
                          color: Colors.white.withOpacity(0.3),
                          offset: const Offset(-5, -5), // Top-left light source
                          blurRadius: 10,
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          // Slightly darker/subtle color for depth
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(5, 5), // Bottom-right shadow
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],

                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        width: 1,
                        color: Colors.black.withOpacity(
                          0.4,
                        ), // Glassy look ke liye light border
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Your Response: ${_userRsvpStatus == 1
                            ? '✅ Going'
                            : _userRsvpStatus == 2
                            ? '❌ Not Going'
                            : '🤔 Maybe'}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _updateRsvp, // Wapis buttons show karne ke liye
                    child: const Text("Update RSVP"),
                  ),
                ],
              ),
            ] else if (_pendingRsvpType != 0) ...[
              // 🚀 Not Going / Maybe select kiya gaya hai, comment box show karo
              Text(
                "Reason for ${_pendingRsvpType == 2 ? 'Not Going' : 'Maybe'} (Optional)",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: "Enter your comment (optional)",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _commentController.clear,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      // Cancel karke wapis buttons show kar dein
                      setState(() => _pendingRsvpType = 0);
                    },
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text("Submit Response"),
                    onPressed: () =>
                        _rsvp(_pendingRsvpType, _commentController.text),
                  ),
                ],
              ),
            ] else ...[
              // 🚀 Default: Show RSVP buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    icon: const Icon(Icons.check),
                    label: const Text("Going"),
                    // Ab _startRsvpProcess ko call karein
                    onPressed: () => _startRsvpProcess(1),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text("Not Going"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    // Ab _startRsvpProcess ko call karein
                    onPressed: () => _startRsvpProcess(2),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                    ),
                    icon: const Icon(Icons.help_outline),
                    label: const Text("Maybe"),
                    // Ab _startRsvpProcess ko call karein
                    onPressed: () => _startRsvpProcess(3),
                  ),
                ],
              ),
            ],

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
