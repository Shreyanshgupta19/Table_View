import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_view/custom_table/custom_table.dart';
import 'package:table_view/data/dummy_response.dart';
import 'package:table_view/data/dummy_response_model.dart';
import 'package:table_view/riverpod/table_riverpod.dart';

final chatTableProvider = StateNotifierProvider<
    FlexibleTableController<ChatMessage>,
    FlexibleTableState<ChatMessage>>((ref) {
  return FlexibleTableController<ChatMessage>(
    columns: [
      FlexibleColumn<ChatMessage>(
        id: 'id',
        title: 'ID',
        width: 80,
        minWidth: 60,
        cellBuilder: (message) => Text(
          message.id.toString(),
          style: const TextStyle(color: Colors.black87),
        ),
      ),
      FlexibleColumn<ChatMessage>(
        id: 'content',
        title: 'Content',
        width: 300,
        minWidth: 200,
        cellBuilder: (message) => Text(
          message.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.black87),
        ),
      ),
      FlexibleColumn<ChatMessage>(
        id: 'user_id',
        title: 'User ID',
        width: 100,
        cellBuilder: (message) => Text(
          message.userId.toString(),
          style: const TextStyle(color: Colors.black87),
        ),
      ),
      FlexibleColumn<ChatMessage>(
        id: 'room_id',
        title: 'Room ID',
        width: 100,
        cellBuilder: (message) => Text(
          message.roomId.toString(),
          style: const TextStyle(color: Colors.black87),
        ),
      ),
      FlexibleColumn<ChatMessage>(
        id: 'time',
        title: 'Time',
        width: 180,
        cellBuilder: (message) => Text(
          message.time.toString(),
          style: const TextStyle(color: Colors.black87),
        ),
      ),
      FlexibleColumn<ChatMessage>(
        id: 'chat_type',
        title: 'Response By',
        width: 120,
        cellBuilder: (message) => Text(
          message.chatType.toUpperCase(),
          style: TextStyle(
            color: message.chatType == 'bot' ? Colors.blue : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      FlexibleColumn<ChatMessage>(
        id: 'actions',
        title: 'Actions',
        width: 120,
        cellBuilder: (message) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              iconSize: 20,
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () {
                // Handle edit action
              },
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              iconSize: 20,
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () {
                // Handle delete action
              },
            ),
          ],
        ),
      ),
    ],
    onFetchData: (page, pageSize) async {
      await Future.delayed(const Duration(seconds: 1));
      return dataResponse;
    },
    dataConverter: (json) => ChatMessage.fromJson(json),
  );
});
