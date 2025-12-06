import 'package:flutter/material.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return _buildNotificationItem(context, index);
        },
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, int index) {
    final isUnread = index < 3;
    return Container(
      color: isUnread ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(
            _getNotificationIcon(index),
            color: Colors.white,
          ),
        ),
        title: Text(
          _getNotificationTitle(index),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _getNotificationMessage(index),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              '2 hours ago',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        trailing: isUnread
            ? Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () {},
      ),
    );
  }

  IconData _getNotificationIcon(int index) {
    final icons = [
      Icons.info,
      Icons.warning,
      Icons.check_circle,
      Icons.book,
      Icons.notifications,
    ];
    return icons[index % icons.length];
  }

  String _getNotificationTitle(int index) {
    final titles = [
      'Book Due Soon',
      'Overdue Notification',
      'Book Returned Successfully',
      'New Book Available',
      'System Update',
    ];
    return titles[index % titles.length];
  }

  String _getNotificationMessage(int index) {
    final messages = [
      'The book "Algorithm Design" is due in 3 days',
      'The book "Data Structures" is overdue. Please return it as soon as possible.',
      'Your book return has been confirmed',
      'The book you requested "Clean Code" is now available',
      'System maintenance will be performed tomorrow',
    ];
    return messages[index % messages.length];
  }
}
