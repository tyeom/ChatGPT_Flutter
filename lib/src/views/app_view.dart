import 'package:chat_gpt/src/bloc/chat_message_cubit.dart';
import 'package:chat_gpt/src/bloc/chat_message_state.dart';
import 'package:chat_gpt/src/bloc/settings_cubit.dart';
import 'package:chat_gpt/src/bloc/theme_cubit.dart';
import 'package:chat_gpt/src/components/chat_item.dart';
import 'package:chat_gpt/src/components/popup_item_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:popup_card/popup_card.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  ScrollController _listScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    context.read<SettingsCubit>().getSettings();
    context.read<ChatMessageCubit>().getChatMessageData();
  }

  Widget _bodyWidget() {
    return Container(
      margin: const EdgeInsets.all(15),
      child: BlocConsumer<ChatMessageCubit, ChatMessageState>(
        listenWhen: (previous, current) => current is ChatListMessageState,
        listener: (context, state) {
          // ChatListMessageState 상태 변경시 리스트뷰 스크롤 제일 하단으로 이동
          final postion = _listScrollController.position.maxScrollExtent;
          _listScrollController.jumpTo(postion);
        },
        buildWhen: (previous, current) => current is ChatListMessageState,
        builder: (_, state) {
          final chatMessageList =
              (state as ChatListMessageState).chatMessageList;

          return ListView.separated(
            controller: _listScrollController,
            itemCount: chatMessageList.length,
            itemBuilder: (_, index) {
              final chatMessageViewModel = chatMessageList[index];

              return ChatItem(chatMessageViewModel);
            },
            separatorBuilder: (_, index) => const SizedBox(
              height: 10,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _bodyWidget(),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          PopupItemLauncher(
            tag: 'settings',
            child: Icon(Icons.settings),
            popUp: PopUpItem(
              padding: const EdgeInsets.fromLTRB(5, 20, 5, 30),
              color: ThemeData().backgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 2,
              tag: 'settings',
              child: PopupItemSettings(),
            ),
          ),
          IconButton(
              padding: const EdgeInsets.only(bottom: 33),
              onPressed: () {
                context.read<ThemeCubit>().toggleTheme();
              },
              icon: const Icon(Icons.brightness_6)),
          const SizedBox(
            width: 50,
          ),
          Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Image.asset('assets/images/clipart855284.png',
                  height: 100, fit: BoxFit.fill)),
        ],
      ),
    );
  }
}
