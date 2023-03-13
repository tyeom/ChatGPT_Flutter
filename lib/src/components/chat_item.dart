import 'package:chat_gpt/src/bloc/chat_message_cubit.dart';
import 'package:chat_gpt/src/bloc/chat_message_state.dart';
import 'package:chat_gpt/src/bloc/theme_cubit.dart';
import 'package:chat_gpt/src/syntax_highlighter.dart';
import 'package:chat_gpt/src/viewmodels/chat_message_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter_speech/flutter_speech.dart';

class ChatItem extends StatefulWidget {
  ChatMessageViewModel chatMessageViewModel;
  ChatItem(this.chatMessageViewModel, {super.key});

  @override
  State<ChatItem> createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  late TextEditingController _chatTextEditingController;
  final TextEditingController _sendTextEditingController =
      TextEditingController();

  // 음성 인식 관련
  //final String speechRecognition_locale = 'en_US';
  final String speechRecognition_locale = 'ko_KR';
  late SpeechRecognition _speech;
  bool _speechRecognitionAvailable = false;
  bool _isListening = false;
  String _transcription = '';

  @override
  void initState() {
    super.initState();
    if (foundation.defaultTargetPlatform == foundation.TargetPlatform.iOS ||
        foundation.defaultTargetPlatform == foundation.TargetPlatform.android ||
        foundation.defaultTargetPlatform == foundation.TargetPlatform.macOS) {
      _activateSpeechRecognizer();
    }
  }

  void _activateSpeechRecognizer() {
    print('_MyAppState.activateSpeechRecognizer... ');
    _speech = SpeechRecognition();
    _speech.setAvailabilityHandler(_onSpeechAvailability);
    _speech.setRecognitionStartedHandler(_onRecognitionStarted);
    _speech.setRecognitionResultHandler(_onRecognitionResult);
    _speech.setRecognitionCompleteHandler(_onRecognitionComplete);
    _speech.setErrorHandler(_errorHandler);
    _speech.activate(speechRecognition_locale).then((res) {
      setState(() => _speechRecognitionAvailable = res);
    });
  }

  /// 음성 인식 유효성 검증
  void _onSpeechAvailability(bool result) =>
      setState(() => _speechRecognitionAvailable = result);

  /// 음성 인식 시작
  void _onRecognitionStarted() {
    setState(() => _isListening = true);
  }

  /// 음성 인식 결과
  void _onRecognitionResult(String text) {
    print('_MyAppState.onRecognitionResult... $text');
    setState(() {
      _sendTextEditingController.text = text;
      _transcription = text;
    });
  }

  /// 음성 인식 완료
  void _onRecognitionComplete(String text) {
    print('_MyAppState.onRecognitionComplete... $text');
    setState(() => _isListening = false);
  }

  /// 음성 인식 오류 발생
  void _errorHandler() => _activateSpeechRecognizer();

  /// Alt + Enter : 줄바꿈 처리, Enter : Send Key Event 처리
  late final _focusNode = FocusNode(
    onKey: (FocusNode node, RawKeyEvent evt) {
      if (!evt.isAltPressed && evt.logicalKey.keyLabel == 'Enter') {
        if (evt is RawKeyDownEvent) {
          _sendChatMessage();
        }
        return KeyEventResult.handled;
      } else {
        return KeyEventResult.ignored;
      }
    },
  );

  /// 우측 복사, 편집, 대화삭제 컨트롤 표시
  List<Widget> _controlWidget() {
    if (widget.chatMessageViewModel.canRemove == false) {
      return [
        IconButton(
          onPressed: () {
            Clipboard.setData(
                ClipboardData(text: widget.chatMessageViewModel.message));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Copied."),
                duration: Duration(milliseconds: 1000),
              ),
            );
          },
          iconSize: 17,
          icon: const Icon(Icons.copy),
          tooltip: 'Copy',
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
      ];
    }

    if (widget.chatMessageViewModel.message.isNotEmpty &&
        widget.chatMessageViewModel.result != null) {
      return [
        IconButton(
          onPressed: () {
            Clipboard.setData(
                ClipboardData(text: widget.chatMessageViewModel.message));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Copied."),
                duration: Duration(milliseconds: 1000),
              ),
            );
          },
          iconSize: 17,
          icon: const Icon(Icons.copy),
          tooltip: 'Copy',
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        IconButton(
          onPressed: () {
            context
                .read<ChatMessageCubit>()
                .editChatMessage(widget.chatMessageViewModel);
          },
          iconSize: 17,
          icon: const Icon(Icons.edit),
          tooltip: 'Edit',
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        IconButton(
          onPressed: () {
            context
                .read<ChatMessageCubit>()
                .removeChatMessage(widget.chatMessageViewModel);
          },
          iconSize: 17,
          icon: const Icon(Icons.delete),
          tooltip: 'Remove',
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
      ];
    }

    if (widget.chatMessageViewModel.message.isNotEmpty &&
        widget.chatMessageViewModel.result == null) {
      return [
        IconButton(
          onPressed: () {
            Clipboard.setData(
                ClipboardData(text: widget.chatMessageViewModel.message));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Copied."),
                duration: Duration(milliseconds: 1000),
              ),
            );
          },
          iconSize: 17,
          icon: const Icon(Icons.copy),
          tooltip: 'Copy',
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        IconButton(
          onPressed: () {
            context
                .read<ChatMessageCubit>()
                .removeChatMessage(widget.chatMessageViewModel);
          },
          iconSize: 17,
          icon: const Icon(Icons.delete),
          tooltip: 'Remove',
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
      ];
    }

    return [];
  }

  /// 음성 인식 시작
  void _start() {
    _speech.activate(speechRecognition_locale).then((_) {
      return _speech.listen().then((result) {
        print('SpeechRecognition start => result : $result');
        setState(() {
          _isListening = result;
        });
      });
    });
  }

  /// 음성 인식 버튼 위짓
  List<Widget> _displaySpeechRecognitionWidget() {
    if (foundation.defaultTargetPlatform == foundation.TargetPlatform.iOS ||
        foundation.defaultTargetPlatform == foundation.TargetPlatform.android ||
        foundation.defaultTargetPlatform == foundation.TargetPlatform.macOS) {
      return [
        const SizedBox(
          width: 15,
        ),

        // 음성 인식 버튼
        Container(
            height: 50,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.all(
                  color: const Color.fromARGB(255, 0, 0, 0), width: 1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: IconButton(
              onPressed: () {
                if (_speechRecognitionAvailable && !_isListening) {
                  _start();
                }
              },
              icon: const Icon(Icons.mic),
              tooltip: 'Voice recognition',
              hoverColor: Colors.transparent,
            )),
      ];
    } else {
      return [];
    }
  }

  /// 메세지 입력 TextField 표시
  Widget _displayMessageInputWidget(ChatMessageViewModel chatMessage) {
    // Editing 모드가 아니고, 지난 대화기록은 user 메세지 Input TextField 표시 하지 않는다.
    if (chatMessage.isEditing == false && chatMessage.isSent == true) {
      return Container();
    }

    // Editing 모드
    if (chatMessage.isEditing =
        true && chatMessage.result != null && chatMessage.message.isNotEmpty) {
      _sendTextEditingController.text = chatMessage.message;
    }

    // ChatGPT 답변 후 user 메세지 Input TextField 표시
    return Row(children: [
      Expanded(
        child: Container(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            decoration: BoxDecoration(
              border: Border.all(
                  color: const Color.fromARGB(255, 0, 0, 0), width: 1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: RawKeyboardListener(
              focusNode: _focusNode,
              child: TextField(
                controller: _sendTextEditingController,
                maxLength: null,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Ask me anyting',
                    hintStyle:
                        TextStyle(fontSize: 15, overflow: TextOverflow.clip)),
              ),
            )),
      ),

      const SizedBox(
        width: 15,
      ),

      // 전송 버튼
      Container(
          height: 50,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            border:
                Border.all(color: const Color.fromARGB(255, 0, 0, 0), width: 1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: IconButton(
            onPressed: () => _sendChatMessage(),
            icon: const Icon(Icons.send),
            tooltip: 'Send',
            hoverColor: Colors.transparent,
          )),
      ..._displaySpeechRecognitionWidget(),
    ]);
  }

  /// 채팅 메세지 및 메세지 전송 TextField 표시
  List<Widget> _displayChatMessage(ChatMessageViewModel chatMessage) {
    // system 메세지
    if (chatMessage.canRemove == false) {
      _chatTextEditingController =
          TextEditingController(text: chatMessage.message);
      return [
        // system 메세지 TextField
        TextField(
          readOnly: true,
          controller: _chatTextEditingController,
          maxLength: null,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(border: InputBorder.none),
        ),
      ];
    }

    // user의 메세지
    if (chatMessage.message.isNotEmpty && chatMessage.result != null) {
      _chatTextEditingController =
          TextEditingController(text: chatMessage.message);
      return [
        // user 입력 TestField
        TextField(
          readOnly: true,
          controller: _chatTextEditingController,
          maxLength: null,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(border: InputBorder.none),
        )
      ];
    }

    // ChatGPT의 답변 메세지
    if (chatMessage.message.isNotEmpty && chatMessage.result == null) {
      return [
        BlocBuilder<ThemeCubit, ThemeData>(
          builder: (_, theme) {
            // ChatGPT 답변 Markdown
            return MarkdownBody(
                selectable: true,
                syntaxHighlighter: DartSyntaxHighlighter(
                    theme.brightness == Brightness.dark
                        ? SyntaxHighlighterStyle.darkThemeStyle()
                        : SyntaxHighlighterStyle.lightThemeStyle()),
                data: chatMessage.message,
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                    .copyWith(textAlign: WrapAlignment.start)
                    .copyWith(
                        p: Theme.of(context)
                            .textTheme
                            .bodyText1
                            ?.copyWith(fontSize: 15.0)));
          },
        )
      ];

      // _chatTextEditingController =
      //     TextEditingController(text: chatMessage.message);
      // return [
      //   // ChatGPT 답변 TextField
      //   TextField(
      //       readOnly: true,
      //       enabled: false,
      //       controller: _chatTextEditingController,
      //       maxLength: null,
      //       maxLines: null,
      //       keyboardType: TextInputType.multiline,
      //       decoration: const InputDecoration(border: InputBorder.none)),
      // ];
    }

    return [];
  }

  void _sendChatMessage() {
    if (widget.chatMessageViewModel.isEditing) {
      widget.chatMessageViewModel.message = '';
    }

    widget.chatMessageViewModel.prompt = _sendTextEditingController.text;
    context
        .read<ChatMessageCubit>()
        .sendChatMessage(widget.chatMessageViewModel);
  }

  Widget _awaitingWidget(ChatMessageViewModel chatMessage) {
    if (chatMessage.isAwaiting) {
      return const LinearProgressIndicator();
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: BoxDecoration(
                border: Border.all(
                    color: const Color.fromARGB(255, 181, 181, 181), width: 1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: BlocBuilder<ChatMessageCubit, ChatMessageState>(
                builder: (_, state) {
                  if (state is ChatMessageChangeState &&
                      state.chatMessage.hashCode ==
                          widget.chatMessageViewModel.hashCode) {
                    return Column(
                      children: _displayChatMessage(state.chatMessage)
                        ..add(_displayMessageInputWidget(state.chatMessage))
                        ..add(const SizedBox(height: 10))
                        ..add(_awaitingWidget(state.chatMessage)),
                    );
                  }

                  return Column(
                    children: _displayChatMessage(widget.chatMessageViewModel)
                      ..add(_displayMessageInputWidget(
                          widget.chatMessageViewModel))
                      ..add(const SizedBox(height: 10))
                      ..add(_awaitingWidget(widget.chatMessageViewModel)),
                  );
                },
              ),
            ),
          ),
          Column(
            children: _controlWidget(),
          )
        ],
      ),
    );
  }
}
