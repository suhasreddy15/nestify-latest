import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/washing_booking.dart';
import '../services/washing_booking_service.dart';

class OwnerBookingsScreen extends StatefulWidget {
  const OwnerBookingsScreen({Key? key}) : super(key: key);

  @override
  State<OwnerBookingsScreen> createState() => _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends State<OwnerBookingsScreen> {
  final WashingBookingService _bookingService = WashingBookingService();
  DateTime? _selectedFilterDate;

  Future<void> _selectFilterDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedFilterDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedFilterDate = picked;
      });
    }
  }

  void _clearFilter() {
    setState(() {
      _selectedFilterDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Washing Machine Bookings'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _selectedFilterDate == null
                  ? Icons.filter_list
                  : Icons.filter_list_off,
            ),
            onPressed: _selectedFilterDate == null
                ? _selectFilterDate
                : _clearFilter,
            tooltip: _selectedFilterDate == null
                ? 'Filter by date'
                : 'Clear filter',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Display
          if (_selectedFilterDate != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue[50],
              child: Row(
                children: [
                  const Icon(Icons.filter_list, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Showing bookings for ${DateFormat('MMM d, y').format(_selectedFilterDate!)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.blue),
                    onPressed: _clearFilter,
                  ),
                ],
              ),
            ),

          // Statistics Card
          FutureBuilder<int>(
            future: _selectedFilterDate != null
                ? _bookingService.getBookingCountForDate(_selectedFilterDate!)
                : null,
            builder: (context, snapshot) {
              if (_selectedFilterDate == null) return const SizedBox.shrink();
              
              final count = snapshot.data ?? 0;
              return Card(
                margin: const EdgeInsets.all(16),
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.assessment, color: Colors.green, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Bookings',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              count.toString(),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Bookings List
          Expanded(
            child: StreamBuilder<List<WashingBooking>>(
              stream: _selectedFilterDate == null
                  ? _bookingService.getAllBookings()
                  : _bookingService.getBookingsByDate(_selectedFilterDate!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final bookings = snapshot.data ?? [];
                if (bookings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilterDate == null
                              ? 'No upcoming bookings'
                              : 'No bookings for selected date',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Group bookings by date
                final Map<String, List<WashingBooking>> groupedBookings = {};
                for (var booking in bookings) {
                  final dateKey = DateFormat('yyyy-MM-dd').format(booking.date);
                  if (!groupedBookings.containsKey(dateKey)) {
                    groupedBookings[dateKey] = [];
                  }
                  groupedBookings[dateKey]!.add(booking);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: groupedBookings.length,
                  itemBuilder: (context, index) {
                    final dateKey = groupedBookings.keys.elementAt(index);
                    final dateBookings = groupedBookings[dateKey]!;
                    final date = dateBookings.first.date;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Header
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  color: Colors.blue[700], size: 20),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('EEEE, MMMM d, y').format(date),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Chip(
                                label: Text('${dateBookings.length}'),
                                backgroundColor: Colors.blue[100],
                              ),
                            ],
                          ),
                        ),

                        // Bookings for this date
                        ...dateBookings.map((booking) =>
                            _buildBookingCard(booking)),

                        const SizedBox(height: 16),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(WashingBooking booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: const Icon(Icons.person, color: Colors.blue),
        ),
        title: Text(
          booking.studentName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  booking.time,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Booked on ${DateFormat('MMM d, h:mm a').format(booking.timestamp)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Confirmed',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
