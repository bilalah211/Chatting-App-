import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connect/model/messages/message.dart';
import 'package:connect/screens/home_screen.dart';
import 'package:connect/screens/view_profile_screen.dart';
import 'package:connect/widgets/messages.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../api/apis.dart';
import '../components/utils/readable_date_time_format.dart';
import '../model/chat_user/chat_user.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> messages = [];
  final messageC = TextEditingController();
  bool showEmoji = false;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
            onWillPop: () {
              if (showEmoji) {
                setState(() => showEmoji = !showEmoji);
                return Future.value(false);
              } else {
                return Future.value(true);
              }
            },
            child: Scaffold(
              appBar: AppBar(
                elevation: 1,
                automaticallyImplyLeading: false,
                flexibleSpace: _appBar(),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: StreamBuilder(
                        stream: APIs.getAllMessages(widget.user),
                        builder: (context, snapshot) {
                          print(snapshot.error);
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                            case ConnectionState.none:
                            case ConnectionState.active:
                            case ConnectionState.done:
                              final data = snapshot.data?.docs;
                              messages = data!
                                      .map((e) => Message.fromJson(e.data()))
                                      .toList() ??
                                  [];
                              if (messages.isNotEmpty) {
                                return ListView.builder(
                                    physics: BouncingScrollPhysics(),
                                    reverse: true,
                                    itemCount: messages.length,
                                    itemBuilder: (context, index) {
                                      return MessageCard(
                                        message: messages[index],
                                      );
                                    });
                              } else {
                                return Center(
                                    child: Text('Say Hi! 👋',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 1,
                                          fontSize: 20,
                                        )));
                              }
                          }
                        }),
                  ),
                  _chatInput(),
                  if (showEmoji)
                    SizedBox(
                      height: height * 0.34,
                      child: EmojiPicker(
                        textEditingController: messageC,
                        // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                        config: Config(
                          bgColor: Colors.amber.shade50,
                          columns: 8,
                          emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                        ),
                      ),
                    )
                ],
              ),
            )),
      ),
    );
  }

  Widget _appBar() {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return ViewProfileScreen(user: widget.user);
        }));
      },
      child: StreamBuilder(
          stream: APIs.getUserInfo(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
            return Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                  child: IconButton(
                      onPressed: () {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (_) {
                          return HomeScreen();
                        }));
                      },
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black45,
                      )),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: CachedNetworkImage(
                    height: height * 0.10,
                    width: width * 0.12,
                    imageUrl: widget.user.image,
                    errorWidget: (context, url, error) =>
                        CircleAvatar(child: Icon(CupertinoIcons.person)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        list.isNotEmpty ? list[0].name : widget.user.name,
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        list.isNotEmpty
                            ? list[0].isOnline
                                ? 'Online'
                                : MyDateUtil.getLastActiveTime(
                                    context: context,
                                    lastActive: list[0].lastActive)
                            : MyDateUtil.getLastActiveTime(
                                context: context,
                                lastActive: widget.user.lastActive),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      )
                    ],
                  ),
                )
              ],
            );
          }),
    );
  }

  Widget _chatInput() {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.02),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            showEmoji = !showEmoji;
                          });
                        },
                        icon: Icon(
                          Icons.emoji_emotions,
                          size: 25,
                          color: Colors.amber,
                        )),
                    Expanded(
                        child: SizedBox(
                      height: height * 0.05,
                      child: TextFormField(
                        controller: messageC,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onTap: () {
                          if (showEmoji) setState(() => showEmoji = !showEmoji);
                        },
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(top: 5, left: 4),
                            border:
                                OutlineInputBorder(borderSide: BorderSide.none),
                            hintStyle: TextStyle(
                                letterSpacing: 2, color: Colors.amber),
                            hintText: 'Type.....'),
                      ),
                    )),
                    IconButton(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();

                          // Picking multiple images
                          final List<XFile> images =
                              await picker.pickMultiImage(imageQuality: 70);

                          // uploading & sending image one by one
                          for (var i in images) {
                            log('Image Path: ${i.path}');
                            setState(() => _isUploading = true);
                            await APIs.sendChatImage(widget.user, File(i.path));
                            setState(() => _isUploading = false);
                          }
                        },
                        icon: Icon(
                          Icons.photo,
                          size: 26,
                          color: Colors.amber,
                        )),
                    IconButton(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();

                          // Pick an image
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.camera, imageQuality: 70);
                          if (image != null) {
                            log('Image Path: ${image.path}');
                            setState(() => _isUploading = true);

                            await APIs.sendChatImage(
                                widget.user, File(image.path));
                            setState(() => _isUploading = false);
                          }
                        },
                        icon: Icon(
                          Icons.camera_alt,
                          size: 26,
                          color: Colors.amber,
                        )),
                  ],
                ),
              ),
            ),
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: Size(0, 0),
                  padding:
                      EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
                  backgroundColor: Colors.amber,
                  shape: CircleBorder()),
              onPressed: () {
                if (messageC.text.isNotEmpty) {
                  if (messages.isEmpty) {
                    APIs.sendFirstMessage(
                        widget.user, messageC.text, Type.text);
                    messageC.text = '';
                  } else {
                    APIs.sendMessage(widget.user, messageC.text, Type.text);
                    messageC.text = '';
                  }
                }
              },
              child: Icon(
                Icons.send,
                size: 27,
                color: Colors.white,
              ))
        ],
      ),
    );
  }
}
