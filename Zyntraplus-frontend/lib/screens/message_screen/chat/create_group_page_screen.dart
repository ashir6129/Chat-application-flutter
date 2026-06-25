import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../api_services/chat_service.dart';
import '../../../api_services/user_service.dart';
import '../../../core/app_colors.dart';
import '../../../models/follow_user.dart';
import 'group_chat_screen.dart';

enum CreateChatType { group, page }

/// Public, Private, or Anonymous — same options for groups and pages.
enum ChatPrivacyType {
  public,
  private,
  anonymous,
}

extension ChatPrivacyTypeMeta on ChatPrivacyType {
  String get label => switch (this) {
        ChatPrivacyType.public => 'Public',
        ChatPrivacyType.private => 'Private',
        ChatPrivacyType.anonymous => 'Anonymous',
      };

  String get description => switch (this) {
        ChatPrivacyType.public =>
          'Everyone who sees the link can join. Members and profiles are visible to everyone.',
        ChatPrivacyType.private =>
          'Only people you invite, or who use your link, can join — with admin approval.',
        ChatPrivacyType.anonymous =>
          'Anyone can join from the link, but all users stay hidden. '
          'No names or profile info are shown — even admins only see message text.',
      };

  IconData get icon => switch (this) {
        ChatPrivacyType.public => Iconsax.global,
        ChatPrivacyType.private => Iconsax.lock_1,
        ChatPrivacyType.anonymous => Iconsax.user_remove,
      };
}

/// Shared APK-style flow: privacy → members → name & photo.
class CreateGroupPageScreen extends StatefulWidget {
  final CreateChatType type;

  const CreateGroupPageScreen({
    super.key,
    required this.type,
  });

  @override
  State<CreateGroupPageScreen> createState() => _CreateGroupPageScreenState();
}

class _CreateGroupPageScreenState extends State<CreateGroupPageScreen> {
  int _step = 0;
  ChatPrivacyType _privacy = ChatPrivacyType.public;
  final Set<String> _selected = {};
  final TextEditingController _nameCtrl = TextEditingController();
  List<FollowUser> _contacts = [];
  bool _contactsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  bool _creating = false;

  Future<void> _loadContacts() async {
    try {
      final users = await UserService.getSuggestions(limit: 50);
      if (!mounted) return;
      setState(() {
        _contacts = users;
        _contactsLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _contactsLoading = false);
    }
  }

  bool get _isPage => widget.type == CreateChatType.page;
  String get _entity => _isPage ? 'Page' : 'Group';
  String get _nameHint => _isPage ? 'Page name' : 'Group name';

  bool get _canProceedStep0 => true;

  bool get _canProceedStep1 {
    switch (_privacy) {
      case ChatPrivacyType.private:
        return _selected.isNotEmpty;
      case ChatPrivacyType.public:
      case ChatPrivacyType.anonymous:
        return true;
    }
  }

  bool get _canCreate => _nameCtrl.text.trim().isNotEmpty;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _finishCreate() async {
    if (!_canCreate || _creating) return;
    setState(() => _creating = true);
    try {
      final conversationId = await ChatService.createGroup(
        title: _nameCtrl.text.trim(),
        memberIds: _selected.toList(),
      );
      if (!mounted) return;
      Navigator.pop(context, {
        'type': _isPage ? 'page' : 'group',
        'name': _nameCtrl.text.trim(),
        'privacy': _privacy.name,
        'members': _selected.toList(),
        'conversation_id': conversationId,
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ChatService.errorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  void _next() {
    if (_step == 0 && !_canProceedStep0) return;
    if (_step == 1 && !_canProceedStep1) return;
    if (_step < 2) {
      setState(() => _step++);
      return;
    }
    if (!_canCreate) return;
    _finishCreate();
  }

  String get _stepTitle => switch (_step) {
        0 => 'Privacy',
        1 => _privacy == ChatPrivacyType.anonymous
            ? 'Invite (optional)'
            : 'Add members',
        _ => 'New $_entity',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: AppColors.primaryText(context)),
          onPressed: _back,
        ),
        title: Text(
          _stepTitle,
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_step == 1 &&
              _privacy != ChatPrivacyType.private &&
              _selected.isEmpty)
            TextButton(
              onPressed: _next,
              child: Text(
                'Skip',
                style: TextStyle(color: AppColors.secondaryText(context)),
              ),
            ),
          TextButton(
            onPressed: _step == 0
                ? (_canProceedStep0 ? _next : null)
                : _step == 1
                    ? (_canProceedStep1 ? _next : null)
                    : (_canCreate ? _next : null),
            child: Text(
              _step < 2 ? 'Next' : 'Create',
              style: TextStyle(
                color: AppColors.buttonColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: switch (_step) {
        0 => _buildPrivacyStep(),
        1 => _buildMembersStep(),
        _ => _buildDetailsStep(),
      },
    );
  }

  // ── Step 0: Public / Private / Anonymous ─────────────────────────────────────
  Widget _buildPrivacyStep() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          'Who can join this $_entity?',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText(context),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Choose how members join and whether identities are visible.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.secondaryText(context),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        ...ChatPrivacyType.values.map(_privacyCard),
      ],
    );
  }

  Widget _privacyCard(ChatPrivacyType type) {
    final selected = _privacy == type;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => setState(() => _privacy = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.buttonColor(context).withOpacity(0.1)
                : AppColors.secondaryBackground(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.buttonColor(context)
                  : AppColors.borderLine(context),
              width: selected ? 1.5 : 0.8,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.buttonColor(context).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  type.icon,
                  color: AppColors.buttonColor(context),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          type.label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText(context),
                          ),
                        ),
                        if (type == ChatPrivacyType.anonymous) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.buttonColor(context)
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Hidden IDs',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: AppColors.buttonColor(context),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      type.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText(context),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Iconsax.tick_circle5 : Icons.radio_button_off,
                color: selected
                    ? AppColors.buttonColor(context)
                    : AppColors.mutedText(context),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 1: Members ──────────────────────────────────────────────────────────
  Widget _buildMembersStep() {
    final isAnonymous = _privacy == ChatPrivacyType.anonymous;
    final isPrivate = _privacy == ChatPrivacyType.private;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _membersSubtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText(context),
                  height: 1.4,
                ),
              ),
              if (isPrivate) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.buttonColor(context).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.buttonColor(context).withOpacity(0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.link,
                        size: 18,
                        color: AppColors.buttonColor(context),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'You can also share an invite link later. '
                          'Join requests will need your approval.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryText(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (isAnonymous) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBackground(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderLine(context)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.eye_slash,
                        size: 18,
                        color: AppColors.mutedText(context),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Invited members will not be identifiable in chat. '
                          'Only message text is shown — no avatars or names.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryText(context),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_selected.isNotEmpty && !isAnonymous)
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _selected.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final id = _selected.elementAt(i);
                final c = _contacts.firstWhere((x) => x.id == id);
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
        if (isAnonymous)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Optional — add admins who can moderate without revealing identity.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.mutedText(context),
              ),
            ),
          ),
        Expanded(
          child: _contactsLoading
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
              final selected = _selected.contains(id);
              return ListTile(
                leading: isAnonymous
                    ? CircleAvatar(
                        backgroundColor:
                            AppColors.secondaryBackground(context),
                        child: Icon(
                          Iconsax.user,
                          color: AppColors.mutedText(context),
                          size: 20,
                        ),
                      )
                    : CircleAvatar(
                        backgroundColor: AppColors.secondaryBackground(context),
                        backgroundImage: c.avatarUrl != null && c.avatarUrl!.isNotEmpty
                            ? NetworkImage(c.avatarUrl!)
                            : null,
                        child: c.avatarUrl == null || c.avatarUrl!.isEmpty
                            ? Text(c.initials, style: TextStyle(color: AppColors.buttonColor(context)))
                            : null,
                      ),
                title: Text(
                  isAnonymous ? 'Member ${i + 1}' : c.displayName,
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: isAnonymous
                    ? Text(
                        'Identity hidden in chat',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.mutedText(context),
                        ),
                      )
                    : null,
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
    );
  }

  String get _membersSubtitle {
    switch (_privacy) {
      case ChatPrivacyType.public:
        return _isPage
            ? 'Invite admins or subscribers (optional). Anyone with the link can also join.'
            : 'Invite people you follow (optional). Anyone with the link can join and see members.';
      case ChatPrivacyType.private:
        return _isPage
            ? 'Select at least one admin or subscriber. Others need your approval to join via link.'
            : 'Select at least one member. Others can request to join using your invite link.';
      case ChatPrivacyType.anonymous:
        return 'Optionally invite people — they will appear only as anonymous message text.';
    }
  }

  // ── Step 2: Name, photo, summary ─────────────────────────────────────────────
  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground(context),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderLine(context)),
            ),
            child: Icon(
              _isPage ? Iconsax.global : Iconsax.people,
              size: 40,
              color: AppColors.buttonColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add photo',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.buttonColor(context),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: _nameHint,
              hintStyle: TextStyle(color: AppColors.mutedText(context)),
              filled: true,
              fillColor: AppColors.secondaryBackground(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _privacySummaryCard(),
          const SizedBox(height: 12),
          Text(
            _detailsFooter,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.secondaryText(context),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _privacySummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLine(context)),
      ),
      child: Row(
        children: [
          Icon(
            _privacy.icon,
            color: AppColors.buttonColor(context),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_privacy.label} $_entity',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _privacy.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryText(context),
                    height: 1.35,
                  ),
                ),
                if (_selected.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${_selected.length} invited',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.buttonColor(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _detailsFooter {
    if (_isPage) {
      return 'Pages broadcast updates to subscribers. Only admins can post announcements.';
    }
    return switch (_privacy) {
      ChatPrivacyType.anonymous =>
        'Messages will show text only — no names, photos, or profile details for anyone.',
      ChatPrivacyType.private =>
        'You control who joins. New requests via link need your approval.',
      ChatPrivacyType.public =>
        'Anyone with your link can join. Member profiles stay visible in the group.',
    };
  }
}

void showCreateChatSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBackground(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.mutedText(context),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            ListTile(
              leading: Icon(Iconsax.people, color: AppColors.buttonColor(context)),
              title: Text(
                'New Group',
                style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Public, Private, or Anonymous',
                style: TextStyle(color: AppColors.secondaryText(context)),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final result = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const CreateGroupPageScreen(type: CreateChatType.group),
                  ),
                );
                if (result != null && context.mounted) {
                  final conversationId = result['conversation_id']?.toString();
                  if (conversationId != null && conversationId.isNotEmpty) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroupChatScreen(
                          groupId: conversationId,
                          name: result['name']?.toString() ?? 'Group',
                          memberCount: ((result['members'] as List?)?.length ?? 0) + 1,
                          isAnonymous: result['privacy']?.toString() == 'anonymous',
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Group "${result['name']}" created')),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: Icon(Iconsax.global, color: AppColors.buttonColor(context)),
              title: Text(
                'New Page',
                style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Public, Private, or Anonymous',
                style: TextStyle(color: AppColors.secondaryText(context)),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final result = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const CreateGroupPageScreen(type: CreateChatType.page),
                  ),
                );
                if (result != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Page "${result['name']}" created · ${result['privacy']}',
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}
