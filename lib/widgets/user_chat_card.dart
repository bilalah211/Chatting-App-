import 'package:cached_network_image/cached_network_image.dart';
import 'package:connect/api/apis.dart';
import 'package:connect/screens/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../components/utils/readable_date_time_format.dart';
import '../model/chat_user/chat_user.dart';
import '../model/messages/message.dart';
import 'dialogs/profile_dialogs.dart';

class UserChatCard extends StatefulWidget {
  final ChatUser user;
  const UserChatCard({super.key, required this.user});

  @override
  State<UserChatCard> createState() => _UserChatCardState();
}

class _UserChatCardState extends State<UserChatCard> {
  Message? _message;
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return ChatScreen(user: widget.user);
            }));
          },
          child: StreamBuilder(
            stream: APIs.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data!.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) _message = list[0];

              return ListTile(
                  title: Text(widget.user.name),
                  subtitle: Text(
                      _message != null
                          ? _message!.type == Type.image
                              ? 'image'
                              : _message!.msg
                          : widget.user.about,
                      maxLines: 1),
                  leading: InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (_) => ProfileDialog(user: widget.user));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(height * 0.5),
                      child: CachedNetworkImage(
                        height: height * 0.15,
                        width: width * 0.15,
                        imageUrl: widget.user.image,
                        errorWidget: (context, url, error) =>
                            Icon(CupertinoIcons.person),
                      ),
                    ),
                  ),
                  trailing: _message == null
                      ? null
                      : _message!.read.isEmpty &&
                              _message!.fromId != APIs.user.uid
                          ? Icon(
                              Icons.circle,
                              size: height * 0.02,
                              color: Colors.green,
                            )
                          : Text(
                              MyDateUtil.getLastMessageTime(
                                  context: context, time: _message!.sent),
                              style: const TextStyle(color: Colors.black54)));
            },
          )),
    );
  }
}
