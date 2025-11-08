import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/dinner_vote.dart';
import '../services/dinner_vote_service.dart';

class DinnerVotingSetupScreen extends StatefulWidget {
  const DinnerVotingSetupScreen({Key? key}) : super(key: key);

  @override
  State<DinnerVotingSetupScreen> createState() =>
      _DinnerVotingSetupScreenState();
}

class _DinnerVotingSetupScreenState extends State<DinnerVotingSetupScreen> {
  final DinnerVoteService _voteService = DinnerVoteService();
  final TextEditingController _dishController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _dishController.dispose();
    super.dispose();
  }

  Future<void> _createVoting() async {
    if (_dishController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a dish name')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _voteService.createDinnerVote(_dishController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voting created and notifications sent!'),
            backgroundColor: Colors.green,
          ),
        );
        _dishController.clear();
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
        title: const Text('Dinner Voting Setup'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Create Voting Card
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Today\'s Dinner Vote',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Open voting at 5 PM. Students can vote until 6 PM.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _dishController,
                      decoration: const InputDecoration(
                        labelText: 'Dish Name',
                        hintText: 'e.g., Chicken Biryani',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.restaurant),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _createVoting,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.add_circle),
                        label: Text(_isLoading ? 'Creating...' : 'Create Voting'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Today's Vote Status
            FutureBuilder<DinnerVote?>(
              future: _voteService.getTodayVote(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final todayVote = snapshot.data;
                if (todayVote == null) {
                  return Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No voting created for today',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return _buildTodayVoteCard(todayVote);
              },
            ),

            // Voting History
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voting History',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<List<DinnerVote>>(
                      stream: _voteService.getVotingHistory(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final votes = snapshot.data ?? [];
                        if (votes.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text('No voting history yet'),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: votes.length,
                          itemBuilder: (context, index) {
                            return _buildHistoryItem(votes[index]);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayVoteCard(DinnerVote vote) {
    final isVotingOpen = _voteService.isVotingOpen();
    final totalVotes = vote.yesCount + vote.noCount;

    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isVotingOpen ? Icons.check_circle : Icons.lock_clock,
                  color: isVotingOpen ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  isVotingOpen ? 'Voting Open' : 'Voting Closed',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isVotingOpen ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              vote.dishName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildVoteCountCard(
                    'Yes',
                    vote.yesCount,
                    Colors.green,
                    totalVotes,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVoteCountCard(
                    'No',
                    vote.noCount,
                    Colors.red,
                    totalVotes,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Total Votes: $totalVotes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Created at: ${DateFormat('h:mm a').format(vote.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (!isVotingOpen) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _showVoteDetails(vote),
                icon: const Icon(Icons.people),
                label: const Text('View All Responses'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVoteCountCard(
      String label, int count, Color color, int total) {
    final percentage = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            '$percentage%',
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(DinnerVote vote) {
    final totalVotes = vote.yesCount + vote.noCount;
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue[100],
        child: const Icon(Icons.restaurant, color: Colors.blue),
      ),
      title: Text(vote.dishName),
      subtitle: Text(
        '${DateFormat('MMM d, y').format(vote.date)} • $totalVotes votes',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSmallVoteChip('👍 ${vote.yesCount}', Colors.green),
          const SizedBox(width: 4),
          _buildSmallVoteChip('👎 ${vote.noCount}', Colors.red),
        ],
      ),
      onTap: () => _showVoteDetails(vote),
    );
  }

  Widget _buildSmallVoteChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showVoteDetails(DinnerVote vote) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Vote Responses',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  vote.dishName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Divider(height: 24),
                Expanded(
                  child: StreamBuilder<List<VoteResponse>>(
                    stream: _voteService.getVoteResponses(vote.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final responses = snapshot.data ?? [];
                      if (responses.isEmpty) {
                        return const Center(child: Text('No responses yet'));
                      }

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: responses.length,
                        itemBuilder: (context, index) {
                          final response = responses[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: response.vote == 'yes'
                                  ? Colors.green[100]
                                  : Colors.red[100],
                              child: Icon(
                                response.vote == 'yes'
                                    ? Icons.thumb_up
                                    : Icons.thumb_down,
                                color: response.vote == 'yes'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            title: Text(response.studentName),
                            subtitle: Text(
                              DateFormat('h:mm a').format(response.timestamp),
                            ),
                            trailing: Chip(
                              label: Text(
                                response.vote.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: response.vote == 'yes'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
