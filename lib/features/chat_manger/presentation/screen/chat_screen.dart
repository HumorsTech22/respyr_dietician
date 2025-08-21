import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../client-dashboard/model/dietitian_model.dart';

import '../../data/bloc/chat_bloc.dart';
import '../../data/bloc/chat_event.dart';
import '../../data/bloc/chat_state.dart';
import '../../data/repository/chat_repository.dart';


class ChatScreen extends StatefulWidget {
  final DietitianModel dietitianModel;

  const ChatScreen({super.key, required this.dietitianModel});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();



  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _setStatusBarColor();
  }

  void _setStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setStatusBarColor(); // Re-apply when returning from another screen
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ChatUser sender = ChatUser(id: 'profile1', firstName: 'Client');
    final ChatUser receiver = ChatUser(id: 'diet001', firstName: widget.dietitianModel.name);
    return WillPopScope(
      onWillPop: () async {return true;},
      child: BlocProvider(
        create: (_) => ChatBloc(
          repository: ChatRepository(sender: sender, receiver: receiver),
        ),
        child: Scaffold(
          body: BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              if (state is ChatLoaded) {
                return SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
                        color: Colors.white,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_outlined),
                            ),
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(widget.dietitianModel.logo),
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.dietitianModel.name,
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF252525),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    height: 1.10,
                                    letterSpacing: -0.30,
                                  ),
                                ),
                                Text(
                                  "Last seen today",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF535359),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -0.24,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.grey.shade300,
                          child: DashChat(
                            currentUser: sender,
                            messages: state.messages,
                            messageOptions: const MessageOptions(
                              showTime: true,
                              currentUserContainerColor: Color(0xFF308BF9),
                            ),
                            inputOptions: InputOptions(
                              textController: _textController,
                              onTextChange: (text) {
                                context.read<ChatBloc>().add(UpdateTyping(text.isNotEmpty));
                              },
                            ),
                            onSend: (ChatMessage message) {
                              context.read<ChatBloc>().add(SendMessage(message.text));
                              _textController.clear();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is ChatError) {
                return Center(child: Text(state.message));
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }



}
