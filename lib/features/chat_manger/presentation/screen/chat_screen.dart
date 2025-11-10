import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';

import '../../../../client-dashboard/data/model/dietitian_model.dart';
import '../../../profile_info/data/model/dietician_detail_model.dart';
import '../../data/bloc/chat_bloc.dart';
import '../../data/bloc/chat_event.dart';
import '../../data/bloc/chat_state.dart';
import '../../data/repository/chat_repository.dart';

class ChatScreen extends StatefulWidget {
  final DietitianDetailModel dietitianModel;
  final ClientProfileModel clientProfileModel;

  const ChatScreen({
    super.key,
    required this.dietitianModel,
    required this.clientProfileModel,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  ChatMessage? _replyingTo;

  // Per-screen status/navigation bar style
  static const SystemUiOverlayStyle _kUiStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.red,                 // status bar bg
    statusBarIconBrightness: Brightness.light,  // ANDROID icons: white
    statusBarBrightness: Brightness.light,       // iOS text: white
    systemNavigationBarColor: Colors.white,     // nav bar (Android)
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ChatUser sender = ChatUser(
      id: widget.clientProfileModel.profileId,
      firstName: widget.clientProfileModel.profileName,
    );
    final ChatUser receiver = ChatUser(
      id: widget.dietitianModel.dietitianId,
      firstName: widget.dietitianModel.name,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _kUiStyle, // <-- this enforces the bar colors for this page
      child: WillPopScope(
        onWillPop: () async => true,
        child: BlocProvider(
          create: (_) => ChatBloc(
            repository: ChatRepository(sender: sender, receiver: receiver),
          ),
          child: Scaffold(

            appBar: AppBar(
              title: Row(
                spacing: 10,
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundImage:
                    NetworkImage(widget.dietitianModel.logoUrl),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.dietitianModel.name,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.26,
                          letterSpacing: -0.32,
                        ),
                      ),
                      Text("Last seen at 8:30 pm",
                        style: GoogleFonts.poppins(
                          color: Colors.black.withValues(alpha: 0.62),
                          fontSize: 8,
                          fontWeight: FontWeight.w400,
                          height: 1.26,
                          letterSpacing: -0.16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight, // 90deg
                    colors: [
                      Color.fromRGBO(48, 139, 249, 0.44), // rgba(48, 139, 249, 0.44)
                      Color.fromRGBO(143, 194, 255, 0.29), // rgba(143, 194, 255, 0.29)
                    ],
                  ),
                ),
              ),
              elevation: 0,
              iconTheme: const IconThemeData(
                color: Color(0xFF252525), // 👈 change back icon color here
              ),
            ),
            body: BlocBuilder<ChatBloc, ChatState>(



              builder: (context, state) {




                if (state is ChatLoaded) {
                  return SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header


                        // Chat
                        Expanded(
                          child: Container(
                            color: Colors.white,
                            child: DashChat(
                              currentUser: sender,
                              messages: state.messages,
                              messageOptions: MessageOptions(
                                showTime: true,
                                currentUserContainerColor:
                                const Color(0xFF308BF9),
                                onPressMessage: (msg) {
                                  setState(() => _replyingTo = msg);
                                },
                                onLongPressMessage: (msg) {
                                  setState(() => _replyingTo = msg);
                                },
                              ),
                              inputOptions: InputOptions(
                                textController: _textController,
                                onTextChange: (text) {
                                  context
                                      .read<ChatBloc>()
                                      .add(UpdateTyping(text.isNotEmpty));
                                },
                              ),
                              scrollToBottomOptions:
                              const ScrollToBottomOptions(disabled: false),
                              onSend: (ChatMessage raw) {
                                final replyPrefix = _replyingTo != null
                                    ? '↩️ ${_replyingTo!.user.firstName ?? ''}: '
                                    '${_replyingTo!.text}\n—\n'
                                    : '';
                                final fullText = '$replyPrefix${raw.text}';
                                context
                                    .read<ChatBloc>()
                                    .add(SendMessage(fullText));
                                _textController.clear();
                                setState(() => _replyingTo = null);
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
      ),
    );
  }
}
