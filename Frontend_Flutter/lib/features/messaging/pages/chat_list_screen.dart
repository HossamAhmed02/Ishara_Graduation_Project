import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ishara/core/constants/constants.dart';
import 'package:ishara/core/theme/theme.dart';
import 'package:ishara/features/messaging/cubit/chat_list_cubit.dart';
import 'package:ishara/features/messaging/cubit/chat_cubit.dart';
import 'package:ishara/features/messaging/cubit/contacts_cubit.dart';
import 'package:ishara/features/messaging/cubit/contacts_state.dart';
import 'package:ishara/features/messaging/cubit/search_contacts_cubit.dart';
import 'package:ishara/features/messaging/cubit/search_contacts_state.dart';
import 'package:ishara/features/messaging/data/models/contact_model.dart';
import 'package:ishara/features/messaging/data/models/user_model.dart';
import 'package:ishara/features/messaging/pages/chat_screen.dart';
import 'package:ishara/main.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin
    implements RouteAware {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late final ContactsCubit _contactsCubit;
  late AnimationController _animController;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animController.dispose();
    _contactsCubit.close();
    super.dispose();
  }

  @override
  void didPopNext() {
    context.read<ChatListCubit>().loadRecentChats();
  }

  @override
  void didPush() {}
  @override
  void didPop() {}
  @override
  void didPushNext() {}
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _contactsCubit = ContactsCubit();
    context.read<ChatListCubit>().loadRecentChats();
  }

  void _toggleSearch() {
    setState(() {
      if (_isSearching) {
        _isSearching = false;
        _searchController.clear();
        _searchFocusNode.unfocus();
      } else {
        _isSearching = true;
        Future.delayed(const Duration(milliseconds: 100), () {
          _searchFocusNode.requestFocus();
        });
      }
    });
  }

  Widget _buildBadge(int count) {
    if (count == 0) return const SizedBox.shrink();
    final label = count > 99 ? '99+' : '$count';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      decoration: BoxDecoration(
        color: AppColors.buttonPrimary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAvatar(String name, {bool isOnline = false}) {
    final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Stack(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.gradientMiddle, AppColors.gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gradientEnd.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              letter,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (isOnline)
          Positioned(
            right: 1,
            bottom: 1,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChatItem(
    ChatUser user,
    int index,
    Set<String> onlineUserIds,
    String currentUserId,
  ) {
    final delay = (index * 0.15).clamp(0.0, 1.0);
    final end = (delay + 0.4).clamp(0.0, 1.0);
    final itemAnimation = CurvedAnimation(
      parent: _animController,
      curve: Interval(delay, end, curve: Curves.easeOutCubic),
    );
    final isOnline = onlineUserIds.contains(user.id);

    return FadeTransition(
      opacity: itemAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(itemAnimation),
        child: Column(
          children: [
            InkWell(
              onTap: () async {
                context.read<ChatListCubit>().markChatAsRead(user.id);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (_) => ChatCubit(otherUserId: user.id),
                      child: ChatScreen(
                        user: user,
                        currentUserId: currentUserId,
                      ),
                    ),
                  ),
                );
                if (mounted) {
                  await context.read<ChatListCubit>().loadRecentChats();
                  setState(() {});
                }
              },
              splashColor: AppColors.buttonSecondary.withValues(alpha: 0.15),
              highlightColor: AppColors.buttonSecondary.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    _buildAvatar(user.name, isOnline: isOnline),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.lastMessage,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: user.unreadCount > 0
                                      ? AppColors.textPrimary.withValues(
                                          alpha: 0.7,
                                        )
                                      : AppColors.textSecondary,
                                  fontSize: 14,
                                  fontWeight: user.unreadCount > 0
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 65,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            user.lastTime,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: user.unreadCount > 0
                                      ? AppColors.buttonPrimary
                                      : AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: user.unreadCount > 0
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                          ),
                          const SizedBox(height: 6),
                          _buildBadge(user.unreadCount),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 86),
              child: Divider(
                height: 1,
                thickness: 0.5,
                color: AppColors.textSecondary.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 72,
            color: AppColors.textSecondary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to start a chat',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showNewChatSheet(String currentUserId) {
    _contactsCubit.getMyContacts();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: _contactsCubit,
        child: _ContactsSheet(
          onContactTap: (user) {
            Navigator.pop(sheetContext);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (_) => ChatCubit(otherUserId: user.id),
                  child: ChatScreen(user: user, currentUserId: currentUserId),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openSearchUserScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => SearchContactsCubit(),
          child: const _SearchUserScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      appBar: AppBar(
        toolbarHeight: 115,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        flexibleSpace: Container(
          decoration: AppTheme.gradientWithRadius(radius: 30),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: _isSearching
              ? TextField(
                  key: const ValueKey('search_field'),
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: 'Search conversations...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                )
              : const Text(
                  key: ValueKey('title'),
                  'Messaging',
                  style: TextStyle(
                    fontFamily: 'Fraunces',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 34,
                  ),
                ),
        ),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) =>
                  RotationTransition(turns: animation, child: child),
              child: Icon(
                _isSearching ? Icons.close_rounded : Icons.search_rounded,
                key: ValueKey(_isSearching),
              ),
            ),
            color: Colors.white,
            onPressed: _toggleSearch,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocBuilder<ChatListCubit, ChatListState>(
        builder: (context, state) {
          if (state is ChatListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ChatListError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.message,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<ChatListCubit>().loadRecentChats(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ChatListLoaded) {
            final currentUserId = state.currentUserId;

            final users = _isSearching && _searchController.text.isNotEmpty
                ? state.users
                      .where(
                        (u) => u.name.toLowerCase().contains(
                          _searchController.text.trim().toLowerCase(),
                        ),
                      )
                      .toList()
                : state.users;

            final hasNoResults =
                _isSearching &&
                _searchController.text.isNotEmpty &&
                users.isEmpty;

            if (state.users.isEmpty) return _buildEmptyState();
            if (hasNoResults) return _buildSearchEmpty();

            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: users.length,
              itemBuilder: (context, index) => _buildChatItem(
                users[index],
                index,
                state.onlineUserIds,
                currentUserId,
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: BlocBuilder<ChatListCubit, ChatListState>(
        builder: (context, state) {
          final currentUserId = state is ChatListLoaded
              ? state.currentUserId
              : '';
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 46,
                height: 46,
                child: FloatingActionButton(
                  heroTag: 'addContact',
                  onPressed: () => _openSearchUserScreen(),
                  backgroundColor: AppColors.buttonPrimary,
                  elevation: 4,
                  child: const Icon(
                    Icons.person_add_alt_1,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FloatingActionButton(
                heroTag: 'newChat',
                onPressed: () => _showNewChatSheet(currentUserId),
                backgroundColor: AppColors.buttonPrimary,
                elevation: 4,
                child: const Icon(
                  Icons.chat_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── _ContactsSheet ───────────────────────────────────
class _ContactsSheet extends StatefulWidget {
  final ValueChanged<ChatUser> onContactTap;
  const _ContactsSheet({required this.onContactTap});

  @override
  State<_ContactsSheet> createState() => _ContactsSheetState();
}

class _ContactsSheetState extends State<_ContactsSheet> {
  final TextEditingController _contactSearchCtrl = TextEditingController();

  @override
  void dispose() {
    _contactSearchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    Text(
                      'New Chat',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      color: AppColors.textSecondary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _contactSearchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search contacts...',
                    hintStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.fieldBorderRadius,
                      ),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BlocConsumer<ContactsCubit, ContactsState>(
                  listener: (context, state) {
                    if (state is ContactsFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is ContactsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is ContactsFailure) {
                      if (state.previousContacts != null &&
                          state.previousContacts!.isNotEmpty) {
                        return _buildContactsList(
                          context,
                          state.previousContacts!,
                          scrollController,
                        );
                      }
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              state.message,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () =>
                                  context.read<ContactsCubit>().getMyContacts(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }
                    if (state is ContactsLoaded) {
                      return _buildContactsList(
                        context,
                        state.contacts,
                        scrollController,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactsList(
    BuildContext context,
    List<ContactModel> contacts,
    ScrollController scrollController,
  ) {
    final query = _contactSearchCtrl.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? contacts
        : contacts.where((c) => c.name.toLowerCase().contains(query)).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_search_rounded,
              size: 48,
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              'No contacts found',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final contact = filtered[index];
        final letter = contact.name.isNotEmpty
            ? contact.name[0].toUpperCase()
            : '?';
        return InkWell(
          onTap: () => widget.onContactTap(
            ChatUser.fromContact(
              id: contact.id,
              name: contact.name,
              email: contact.email,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.gradientMiddle, AppColors.gradientEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gradientEnd.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        contact.email,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () =>
                      context.read<ContactsCubit>().deleteContact(contact.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[600],
                    side: BorderSide(color: Colors.red[400]!, width: 1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Remove',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── _SearchUserScreen ───────────────────────────────
class _SearchUserScreen extends StatefulWidget {
  const _SearchUserScreen();

  @override
  State<_SearchUserScreen> createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<_SearchUserScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Contact',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        toolbarHeight: 75,
        flexibleSpace: Container(
          decoration: AppTheme.gradientBackground.copyWith(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<SearchContactsCubit, SearchContactsState>(
        listener: (context, state) {
          if (state is SearchContactsFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: TextField(
                controller: _searchController,
                onSubmitted: (_) => context.read<SearchContactsCubit>().search(
                  _searchController.text,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                  hintText: 'Search by name or email...',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: BlocBuilder<SearchContactsCubit, SearchContactsState>(
                builder: (context, state) {
                  final isLoading = state is SearchContactsLoading;
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => context.read<SearchContactsCubit>().search(
                              _searchController.text,
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 2,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Search',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
            BlocBuilder<SearchContactsCubit, SearchContactsState>(
              builder: (context, state) {
                if (state is SearchContactsInitial) {
                  return const Expanded(child: SizedBox());
                }
                if (state is SearchContactsLoading) {
                  return const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state is SearchContactsFailure) {
                  if (state.previousState != null) {
                    return _buildResultsList(context, state.previousState!);
                  }
                  return Expanded(
                    child: Center(
                      child: Text(
                        state.message,
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  );
                }
                if (state is SearchContactsLoaded) {
                  if (state.results.isEmpty) {
                    return Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_search,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No users found',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return _buildResultsList(context, state);
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(BuildContext context, SearchContactsLoaded state) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: state.results.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.results.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: TextButton(
                  onPressed: () =>
                      context.read<SearchContactsCubit>().loadMore(),
                  child: const Text('Show more'),
                ),
              ),
            );
          }
          final contact = state.results[index];
          final letter = contact.name.isNotEmpty
              ? contact.name[0].toUpperCase()
              : '?';
          final isAdded = state.addedIds.contains(contact.id);
          final isLoading = state.loadingIds.contains(contact.id);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.gradientMiddle, AppColors.gradientEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gradientEnd.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        contact.email,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (isAdded) {
                            context
                                .read<SearchContactsCubit>()
                                .removeContactFromSearch(contact.id);
                          } else {
                            context.read<SearchContactsCubit>().addContact(
                              contact.id,
                            );
                          }
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isLoading
                        ? Colors.grey[400]
                        : isAdded
                        ? Colors.red[600]
                        : Colors.blue[600],
                    side: BorderSide(
                      color: isLoading
                          ? Colors.grey[400]!
                          : isAdded
                          ? Colors.red[400]!
                          : Colors.blue[400]!,
                      width: 1,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isAdded ? Colors.red[400] : Colors.blue[400],
                          ),
                        )
                      : Text(
                          isAdded ? 'Remove' : 'Add',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
