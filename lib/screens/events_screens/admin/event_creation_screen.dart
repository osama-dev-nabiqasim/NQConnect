import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nqconnect/models/event_models/event.dart';
import 'package:nqconnect/services/event_api_service.dart';

/// Screen for HR/Admin to create a new event
class EventCreationScreen extends StatefulWidget {
  final String token; // pass logged-in admin token
  const EventCreationScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<EventCreationScreen> createState() => _EventCreationScreenState();
}

class _EventCreationScreenState extends State<EventCreationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _rsvpDeadline;

  bool _loading = false;

  Future<void> _pickDate(BuildContext ctx, bool isStart) async {
    final picked = await showDatePicker(
      context: ctx,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _rsvpDeadline = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select start & end dates")));
      return;
    }
    if (_rsvpDeadline == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select RSVP deadline")));
      return;
    }

    setState(() => _loading = true);

    try {
      final service = EventApiService(token: widget.token);
      final event = Event(
        eventId: 0,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        rsvpDeadline: _rsvpDeadline!,
        location: _locationCtrl.text.trim(),
        category: _categoryCtrl.text.trim(),
        maxCapacity: int.tryParse(_capacityCtrl.text.trim()) ?? 0,
        coverImageUrl: "",
        attachmentsJson: "",
        organizerUserId: 0,
        isActive: true,
        createdAt: DateTime.now(),
      );

      final created = await service.createEvent(event);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Event created ID: ${created.eventId}")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Failed to create event: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('yyyy-MM-dd');
    return Scaffold(
      appBar: AppBar(title: const Text("Create Event")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (v) => v!.isEmpty ? "Enter title" : null,
              ),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? "Enter description" : null,
              ),
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(labelText: "Location"),
                validator: (v) => v!.isEmpty ? "Enter location" : null,
              ),
              TextFormField(
                controller: _categoryCtrl,
                decoration: const InputDecoration(labelText: "Category"),
              ),
              TextFormField(
                controller: _capacityCtrl,
                decoration: const InputDecoration(labelText: "Max Capacity"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _startDate == null
                          ? "Start Date"
                          : "Start: ${df.format(_startDate!)}",
                    ),
                  ),
                  TextButton(
                    onPressed: () => _pickDate(context, true),
                    child: const Text("Select"),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _endDate == null
                          ? "End Date"
                          : "End: ${df.format(_endDate!)}",
                    ),
                  ),
                  TextButton(
                    onPressed: () => _pickDate(context, false),
                    child: const Text("Select"),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _rsvpDeadline == null
                          ? "RSVP Deadline"
                          : "Deadline: ${df.format(_rsvpDeadline!)}",
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDeadline,
                    child: const Text("Select"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text("Create Event"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
