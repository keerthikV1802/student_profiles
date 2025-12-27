import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  static const _pageSize = 10;

  final PagingController<DocumentSnapshot?, Map<String, dynamic>>
      _pagingController =
      PagingController(firstPageKey: null); // start without last doc

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((lastDoc) {
      _fetchPage(lastDoc);
    });
  }

  Future<void> _fetchPage(DocumentSnapshot? lastDoc) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('audit_logs')
          .orderBy('timestamp', descending: true)
          .limit(_pageSize);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();

      final isLastPage = snapshot.docs.length < _pageSize;
      final logs =
          snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      if (isLastPage) {
        _pagingController.appendLastPage(logs);
      } else {
        final nextPageKey = snapshot.docs.last;
        _pagingController.appendPage(logs, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Audit Logs")),
      body: PagedListView<DocumentSnapshot?, Map<String, dynamic>>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
          itemBuilder: (context, log, index) {
            final actorName = log['actorName'] ?? "Unknown";
            final role = log['designation'] ?? "-";
            final dept = log['dept'] ?? "-";
            final action = log['action'] ?? "did something";
            final target = log['target'] ?? "-";
            final timestamp = (log['timestamp'] as Timestamp?)?.toDate();

            return ListTile(
              
              title: Text(
                "$actorName ($role - $dept) → $action → $target",
                style: const TextStyle(fontSize: 12),
              ),
              
              subtitle: Text(
                timestamp != null
                    ? DateFormat('dd/MM/yyyy hh:mm a').format(timestamp)
                    : "No time",
              ),
            );
          },
        ),
      ),
    );
  }
}
