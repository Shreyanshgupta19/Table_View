import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_view/custom_table/custom_table.dart';
import 'package:table_view/data/dummy_response_model.dart';
import 'package:table_view/data/dummy_response_riverpod/dummy_response_riverpod.dart';
import 'package:table_view/view/multiselect_dropdown.dart';

class ChatTableScreen extends ConsumerWidget {
  const ChatTableScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Chat Messages',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: () => ref.read(chatTableProvider.notifier).refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt_rounded, color: Colors.black87),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return MultiselectDropdown();
              },));
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[50],
        child: FlexibleTable<ChatMessage>(
          controller: chatTableProvider,
          onRowTap: (message) {
            debugPrint('Tapped message: ${message.id}');
          },
          headerStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
          rowHeight: 60,
          showPagination: true,
        ),
      ),
    );
  }
}