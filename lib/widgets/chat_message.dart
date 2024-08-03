import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key});
  @override
  Widget build(BuildContext context) {
    final authenticatorUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshots.hasData || snapshots.data!.docs.isEmpty) {
            return const Center(
              child: Text("No Messages Found!!"),
            );
          }
          if (snapshots.hasError) {
            return const Center(
              child: Text("Something went Wrong"),
            );
          }
          return ListView.builder(
              padding: const EdgeInsets.only(bottom: 40, left: 30, right: 30),
              reverse: true,
              itemCount: snapshots.data!.docs.length,
              itemBuilder: (ctx, index) {
                final chatMessage = snapshots.data!.docs[index].data();
                final nextChatMessage = index + 1 < snapshots.data!.docs.length
                    ? snapshots.data!.docs[index + 1].data()
                    : null;
                final messageUserId = chatMessage['userId'];
                final nextMessageUserId =
                    nextChatMessage == null ? null : nextChatMessage['userId'];
                final nextUserSame = messageUserId == nextMessageUserId;
                if (nextUserSame) {
                  return MessageBubble.next(
                      message: chatMessage['text'],
                      isMe: authenticatorUser.uid == messageUserId);
                } else {
                  return MessageBubble.first(
                      userImage: chatMessage['userimage'],
                      username: chatMessage['username'],
                      message: chatMessage['text'],
                      isMe: authenticatorUser.uid == messageUserId);
                }
              });
        });
  }
}
