import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../api_services/box_service.dart';
import '../api_services/chat_service.dart';
import '../screens/message_screen/main_message_screen/personal_chat_screen.dart';

class ReceiveBoxScreen extends StatelessWidget {
  final Map<String, dynamic> request;

  const ReceiveBoxScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildReceivedCoinsCard(context),
                    const SizedBox(height: 16),
                    _buildNoteCard(context),
                    const SizedBox(height: 16),
                    _buildAboutCard(context),
                    const SizedBox(height: 24),
                    _buildActionButtons(context),
                    const SizedBox(height: 12),
                    _buildPrivacyNote(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back,
                color: AppColors.primaryText(context), size: 24),
          ),
          const SizedBox(width: 12),
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: request['sender_avatar'] != null && request['sender_avatar'].toString().isNotEmpty
                    ? NetworkImage(request['sender_avatar'].toString())
                    : null,
                backgroundColor: AppColors.secondaryBackground(context),
                child: request['sender_avatar'] == null || request['sender_avatar'].toString().isEmpty
                    ? Icon(Icons.person, color: AppColors.secondaryText(context))
                    : null,
              ),
              Positioned(
                bottom: 1,
                right: 1,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A884),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.primaryBackground(context),
                        width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request['sender_username'] ?? 'Someone',
                    style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                Text('Nearby',
                    style: TextStyle(
                        color: AppColors.secondaryText(context), fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.more_horiz,
              color: AppColors.secondaryText(context), size: 22),
        ],
      ),
    );
  }

  Widget _buildReceivedCoinsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  Text(
                    'You received a Box!',
                    style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2218),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFFFD700),
                                Color(0xFFFFA500)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Text('🪙',
                                style: TextStyle(fontSize: 18)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${request['coins'] ?? 50} Coins',
                          style: TextStyle(
                              color: AppColors.primaryText(context),
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoinParticle({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_quote,
                  color: const Color(0xFF9B59B6), size: 20),
              const SizedBox(width: 6),
              Text(
                'Their Note',
                style: TextStyle(
                    color: const Color(0xFF9B59B6),
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            request['note'] ?? 'No note attached.',
            style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 14,
                height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About ${request['sender_username'] ?? 'User'}',
            style: TextStyle(
                color: const Color(0xFF9B59B6),
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: request['sender_avatar'] != null && request['sender_avatar'].toString().isNotEmpty
                        ? NetworkImage(request['sender_avatar'].toString())
                        : null,
                    backgroundColor: AppColors.secondaryBackground(context),
                    child: request['sender_avatar'] == null || request['sender_avatar'].toString().isEmpty
                        ? Icon(Icons.person, color: AppColors.secondaryText(context))
                        : null,
                  ),
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A884),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.secondaryBackground(context),
                            width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(request['sender_username'] ?? 'Someone',
                            style: TextStyle(
                                color: AppColors.primaryText(context),
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('Nearby',
                        style: TextStyle(
                            color: AppColors.secondaryText(context),
                            fontSize: 12)),
                    const SizedBox(height: 6),
                    Text(
                      'Unlock to view bio and connect!',
                      style: TextStyle(
                          color: AppColors.secondaryText(context),
                          fontSize: 12,
                          height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C896)),
                  ),
                ),
              );
              try {
                await BoxService.updateBoxRequestStatus(request['id'].toString(), 'accepted');
                final conversationId = await ChatService.startDirect(request['sender_id'].toString());
                if (context.mounted) {
                  Navigator.pop(context); // Pop loading dialog
                  Navigator.pop(context, true); // Pop screen
                  
                  // Navigate to PersonalChatScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PersonalChatScreen(
                        userId: request['sender_id'].toString(),
                        name: request['sender_username']?.toString() ?? '',
                        avatar: request['sender_avatar']?.toString() ?? '',
                        isOnline: true,
                        conversationId: conversationId,
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Pop loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            icon: const Icon(Icons.check_circle_outline, size: 22),
            label: const Text('Accept & Reply',
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C896),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4D6D)),
                  ),
                ),
              );
              try {
                await BoxService.updateBoxRequestStatus(request['id'].toString(), 'declined');
                if (context.mounted) {
                  Navigator.pop(context); // Pop loading dialog
                  Navigator.pop(context, true); // Pop screen
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Pop loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            icon: const Icon(Icons.cancel_outlined, size: 22),
            label: const Text('Decline Request',
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFF4D6D),
              side: const BorderSide(color: Color(0xFFFF4D6D), width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyNote(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline,
            size: 13, color: AppColors.mutedText(context)),
        const SizedBox(width: 5),
        Text(
          'You control who can message you',
          style:
          TextStyle(color: AppColors.mutedText(context), fontSize: 12),
        ),
      ],
    );
  }
}