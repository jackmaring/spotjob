import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:spotjob/models/chat.dart';
import 'package:spotjob/models/user.dart';
import 'package:spotjob/services/crud_models/chat_crud_model.dart';
import 'package:spotjob/services/update_methods/sjnotification_update_methods.dart';

class ChatUpdateMethods {
  static Future<Chat> createChat({List<String> userIds}) async {
    ChatCRUD chatCrud = ChatCRUD();
    Chat newlyCreatedChat;
    await chatCrud
        .addChat(
      Chat(users: userIds, isVisibleTo: [], lastMessage: Message()),
    )
        .then((chat) {
      newlyCreatedChat = chat;
    });
    return newlyCreatedChat;
  }

  static void updateChat(
      Chat chat, Message message, User currentUser, User otherUser) {
    ChatCRUD chatCrud = ChatCRUD();
    chatCrud.updateChat(
      Chat(
        id: chat.id,
        users: chat.users,
        isVisibleTo: chat.users,
        lastMessage: message,
      ),
    );
  }

  static void removeUserFromIsVisibleTo(Chat chat, User currentUser) {
    ChatCRUD chatCrud = ChatCRUD();
    List<String> isVisibleTo = chat.isVisibleTo;
    if (isVisibleTo.contains(currentUser.id)) {
      isVisibleTo.remove(currentUser.id);
    }
    chatCrud.updateChat(
      Chat(
        id: chat.id,
        users: chat.users,
        isVisibleTo: isVisibleTo,
        lastMessage: chat.lastMessage,
      ),
    );
  }

  static void deleteChat(Chat chat) {
    ChatCRUD chatCrud = ChatCRUD();
    chatCrud.removeChat(chat.id);
  }

  static Future<Message> createMessage({
    String messageContent,
    MessageType messageType,
    User currentUser,
    Chat chat,
  }) async {
    ChatCRUD messageCrud = ChatCRUD();
    Message newMessage = Message(
      uid: currentUser.uid,
      content: messageContent,
      messageType: messageType,
      messageStatus: MessageStatus.unread,
      chatId: chat.id,
      dateCreated: Timestamp.now(),
    );

    await messageCrud.addMessage(chat, newMessage).then(
          (newMessageWithId) => newMessage = newMessageWithId,
        );

    return newMessage;
  }

  static void sendMessage(String message, Chat chat, User currentUser,
      User otherUser, TextEditingController controller) {
    ChatUpdateMethods.createMessage(
      messageContent: message,
      messageType: MessageType.text,
      currentUser: currentUser,
      chat: chat,
    ).then((newMessage) {
      ChatUpdateMethods.updateChat(
        chat,
        newMessage,
        currentUser,
        otherUser,
      );
      SJNotificationUpdateMethods.createMessageNotification(
        senderUser: currentUser,
        acceptorUser: otherUser,
        message: newMessage,
      );
    });
    message = '';
    controller.clear();
  }

  static void makeMessageRead(Chat chat, Message message) {
    ChatCRUD messageCrud = ChatCRUD();
    messageCrud.updateChatMessage(
      chat,
      Message(
        id: message.id,
        uid: message.uid,
        content: message.content,
        messageType: message.messageType,
        messageStatus: MessageStatus.read,
        chatId: message.chatId,
        dateCreated: message.dateCreated,
      ),
    );
  }
}
