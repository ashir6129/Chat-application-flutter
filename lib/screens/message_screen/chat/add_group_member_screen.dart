import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../api_services/chat_service.dart';
import '../../../api_services/user_service.dart';
import '../../../core/app_colors.dart';
import '../../../models/follow_user.dart';

class AddGroupMemberScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String? creatorId;
  final String? creatorName;
  final String? creatorAvatar;
  final List<String> currentMemberIds;

  const AddGroupMemberScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    this.creatorId,
    this.creatorName,
    this.creatorAvatar,
    this.currentMemberIds = const [],
  });

  @override
  State<AddGroupMemberScreen> createState() => _AddGroupMemberScreenState();
}

class _AddGroupMemberScreenState extends State<AddGroupMemberScreen> {
  final Set<String> _selected = {};
  List<FollowUser> _contacts = [];
  bool _loading = true;
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final users = await UserService.getSuggestions(limit: 50);
      if (!mounted) return;
      setState(() {
        _contacts = users;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addMembers() async {
    if (_selected.isEmpty || _adding) return;
    setState(() => _adding = true);
    
    try {
      for (final userId in _selected) {
        await ChatService.addMember(widget.groupId, userId);
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_selected.length} member(s) added')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ChatService.errorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: AppColors.primaryText(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Members',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_selected.isNotEmpty)
            TextButton(
              onPressed: _adding ? null : _addMembers,
              child: Text(
                'Add',
                style: TextStyle(
                  color: AppColors.buttonColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Group Creator Section
          if (widget.creatorId != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLine(context)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.buttonColor(context).withOpacity(0.1),
                    ),
                    child: widget.creatorAvatar != null && widget.creatorAvatar!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              widget.creatorAvatar!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Iconsax.crown,
                                color: AppColors.buttonColor(context),
                                size: 22,
                              ),
                            ),
                          )
                        : Icon(
                            Iconsax.crown,
                            color: AppColors.buttonColor(context),
                            size: 22,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Group Creator',
                              style: TextStyle(
                                color: AppColors.buttonColor(context),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Iconsax.crown,
                              color: AppColors.buttonColor(context),
                              size: 12,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.creatorName ?? 'Unknown',
                          style: TextStyle(
                            color: AppColors.primaryText(context),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          // Selected Members
          if (_selected.isNotEmpty)
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _selected.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final id = _selected.elementAt(i);
                  final c = _contacts.firstWhere((x) => x.id == id, orElse: () => FollowUser(id: id, username: 'User', avatarUrl: null, isVerified: false));
                  return Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.secondaryBackground(context),
                            backgroundImage: c.avatarUrl != null && c.avatarUrl!.isNotEmpty
                                ? NetworkImage(c.avatarUrl!)
                                : null,
                            child: c.avatarUrl == null || c.avatarUrl!.isEmpty
                                ? Text(c.initials, style: TextStyle(color: AppColors.buttonColor(context)))
                                : null,
                          ),
                          Positioned(
                            top: -4,
                            right: -4,
                            child: GestureDetector(
                              onTap: () => setState(() => _selected.remove(id)),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 52,
                        child: Text(
                          c.displayName.split(' ').first,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.secondaryText(context),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          
          // Contact List
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator(color: AppColors.buttonColor(context)))
                : _contacts.isEmpty
                    ? Center(
                        child: Text(
                          'No users found',
                          style: TextStyle(color: AppColors.secondaryText(context)),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _contacts.length,
                        itemBuilder: (_, i) {
                          final c = _contacts[i];
                          final id = c.id;
                          final isCurrentMember = widget.currentMemberIds.contains(id);
                          final selected = _selected.contains(id);
                          
                          if (isCurrentMember) {
                            return const SizedBox.shrink();
                          }
                          
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.secondaryBackground(context),
                              backgroundImage: c.avatarUrl != null && c.avatarUrl!.isNotEmpty
                                  ? NetworkImage(c.avatarUrl!)
                                  : null,
                              child: c.avatarUrl == null || c.avatarUrl!.isEmpty
                                  ? Text(c.initials, style: TextStyle(color: AppColors.buttonColor(context)))
                                  : null,
                            ),
                            title: Text(
                              c.displayName,
                              style: TextStyle(
                                color: AppColors.primaryText(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Icon(
                              selected ? Iconsax.tick_circle5 : Iconsax.record_circle,
                              color: selected
                                  ? AppColors.buttonColor(context)
                                  : AppColors.mutedText(context),
                            ),
                            onTap: () => setState(() {
                              if (selected) {
                                _selected.remove(id);
                              } else {
                                _selected.add(id);
                              }
                            }),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
