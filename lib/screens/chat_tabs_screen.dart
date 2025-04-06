import 'package:flutter/material.dart';
import 'location_chat_screen.dart';
import 'shop_chat_screen.dart';
import 'day_and_shops_chat_screen.dart';

class ChatTabsScreen extends StatefulWidget {
  @override
  _ChatTabsScreenState createState() => _ChatTabsScreenState();
}

class _ChatTabsScreenState extends State<ChatTabsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Bot for Kids'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Prompt 1'),
            Tab(text: 'Prompt 2'),
            Tab(text: 'Prompt 3'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          LocationChatScreen(),
          ShopChatScreen(),
          DayAndShopsChatScreen(),
        ],
      ),
    );
  }
}