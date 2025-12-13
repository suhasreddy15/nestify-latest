import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/dinner_vote.dart';
import '../services/dinner_vote_service.dart';

class DinnerVotingScreen extends StatefulWidget {
  const DinnerVotingScreen({Key? key}) : super(key: key);

  @override
  State<DinnerVotingScreen> createState() => _DinnerVotingScreenState();
}

class _DinnerVotingScreenState extends State<DinnerVotingScreen> {
  final DinnerVoteService _voteService = DinnerVoteService();
  bool _isLoading = false;

  Future<void> _submitVote(String voteId, String vote) async {
    setState(() => _isLoading = true);

    try {
      await _voteService.submitVote(voteId, vote);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Your vote has been recorded: ${vote.toUpperCase()}'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dinner Voting'),
        elevation: 0,
      ),
      body: FutureBuilder<DinnerVote?>(
        future: _voteService.getTodayVote(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final todayVote = snapshot.data;
          if (todayVote == null) {
            return _buildNoVotingCard();
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildVotingCard(todayVote),
                  const SizedBox(height: 20),
                  _buildVotingResults(todayVote),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoVotingCard() {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No Dinner Voting Today',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'The owner hasn\'t set up voting yet.\nCheck back around 5 PM!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVotingCard(DinnerVote vote) {
    final isVotingOpen = vote.isVotingOpen; // Use the model's property

    return FutureBuilder<VoteResponse?>(
      future: _voteService.hasUserVoted(vote.id),
      builder: (context, snapshot) {
        final hasVoted = snapshot.data != null;
        final userVote = snapshot.data;

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Header
                Row(
                  children: [
                    Icon(
                      isVotingOpen ? Icons.schedule : Icons.lock_clock,
                      color: isVotingOpen ? Colors.green : Colors.orange,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isVotingOpen ? 'Voting Open' : 'Voting Closed',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color:
                                      isVotingOpen ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (isVotingOpen && vote.votingDeadline != null)
                            Text(
                              'Vote before ${_formatTime(vote.votingDeadline!)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          if (isVotingOpen && vote.votingDeadline == null)
                            Text(
                              'Vote before 6:00 PM',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                        ],
                      ),
                    ),
                    if (isVotingOpen)
                      _buildCountdownTimer(vote),
                  ],
                ),
                const Divider(height: 24),

                // Dish Information
                Text(
                  'Today\'s Dinner',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.restaurant, size: 32, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        vote.dishName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Voting Status
                if (hasVoted) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: userVote!.vote == 'yes'
                          ? Colors.green[50]
                          : Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: userVote.vote == 'yes'
                            ? Colors.green
                            : Colors.red,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          userVote.vote == 'yes'
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: userVote.vote == 'yes'
                              ? Colors.green
                              : Colors.red,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'You voted: ${userVote.vote.toUpperCase()}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: userVote.vote == 'yes'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              Text(
                                'at ${DateFormat('h:mm a').format(userVote.timestamp)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (isVotingOpen) ...[
                  // Voting Buttons
                  Text(
                    'Will you have dinner today?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              _isLoading ? null : () => _submitVote(vote.id, 'yes'),
                          icon: const Icon(Icons.thumb_up, size: 32),
                          label: const Text(
                            'YES',
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              _isLoading ? null : () => _submitVote(vote.id, 'no'),
                          icon: const Icon(Icons.thumb_down, size: 32),
                          label: const Text(
                            'NO',
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange, width: 2),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lock_clock, color: Colors.orange, size: 32),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Voting closed at 6:00 PM',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Widget _buildCountdownTimer(DinnerVote vote) {
    final now = DateTime.now();
    final deadline = vote.votingDeadline ?? DateTime(now.year, now.month, now.day, 18, 0);
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      return Container();
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer, size: 16, color: Colors.orange),
          const SizedBox(width: 4),
          Text(
            '${hours}h ${minutes}m left',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVotingResults(DinnerVote vote) {
    final totalVotes = vote.yesCount + vote.noCount;
    final yesPercentage =
        totalVotes > 0 ? (vote.yesCount / totalVotes * 100) : 0.0;
    final noPercentage = totalVotes > 0 ? (vote.noCount / totalVotes * 100) : 0.0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Results',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildResultBar('Yes', vote.yesCount, yesPercentage, Colors.green),
            const SizedBox(height: 12),
            _buildResultBar('No', vote.noCount, noPercentage, Colors.red),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Votes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  totalVotes.toString(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultBar(
      String label, int count, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$count (${percentage.toStringAsFixed(1)}%)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 24,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
