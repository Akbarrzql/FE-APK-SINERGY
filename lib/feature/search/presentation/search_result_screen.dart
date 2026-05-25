import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gabungyuk/core/common/color_value.dart';
import 'package:gabungyuk/core/widget/loading_shimmer.dart';
import 'package:gabungyuk/feature/home/model/view_project_model.dart';
import 'package:gabungyuk/feature/home/presentation/detail_collaboration.dart';
import 'package:gabungyuk/feature/search/bloc/search_bloc.dart';
import 'package:gabungyuk/feature/search/bloc/search_event.dart';
import 'package:gabungyuk/feature/search/bloc/search_state.dart';
import 'package:gabungyuk/feature/search/repository/search_repository.dart';
import 'package:gabungyuk/feature/search/presentation/user_detail_view_screen.dart';

import 'widget/search_project_card.dart';
import 'widget/search_user_card.dart';

class SearchResultScreen extends StatefulWidget {
  final String initialQuery;

  const SearchResultScreen({
    super.key,
    required this.initialQuery,
  });

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _searchController;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchBloc(
        searchRepository: SearchRepositoryImpl(),
      )
        ..add(
          widget.initialQuery.trim().isEmpty
              ? ClearSearch()
              : SearchQuery(widget.initialQuery.trim()),
        ),
      child: Scaffold(
        backgroundColor: ColorValue.backgroundColor,
        appBar: AppBar(
          backgroundColor: ColorValue.backgroundColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: ColorValue.textPrimary),
          ),
          title: const Text(
            'Hasil Pencarian',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ColorValue.textPrimary,
            ),
          ),
        ),
        body: _SearchContent(
          searchController: _searchController,
          tabController: _tabController,
        ),
      ),
    );
  }
}

class _ProjectsTab extends StatelessWidget {
  final TextEditingController searchController;

  const _ProjectsTab({required this.searchController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is InitialSearchState || state is SearchCleared) {
          return _EmptyHint(
            icon: Icons.search,
            text: 'Cari proyek',
          );
        }

        if (state is SearchLoading) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: 5,
            itemBuilder: (_, __) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LoadingShimmer(
                width: double.infinity,
                height: 80,
                borderRadius: 12,
              ),
            ),
          );
        }

        if (state is SearchError) {
          return _ErrorView(
            message: state.message,
            onRetry: () {
              final q = searchController.text.trim();
              if (q.isNotEmpty) {
                context.read<SearchBloc>().add(SearchQuery(q));
              }
            },
          );
        }

        if (state is SearchLoaded) {
          final projects = state.result.data?.projects ?? [];

          if (projects.isEmpty) {
            return _EmptyHint(
              icon: Icons.search_off,
              text: 'Tidak ada proyek untuk "${searchController.text}"',
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: projects
                .map(
                  (project) => SearchProjectCard(
                    project: project,
                    onTap: () {
                      final datum = Datum(
                        id: project.id ?? 0,
                        title: project.title ?? 'Untitled',
                        description: project.description ?? '',
                        category: project.category ?? [],
                        status: project.status,
                        repositoryLink: project.repositoryLink,
                        projectPicture: project.projectPicture,
                        owner: Owner(
                          id: 0,
                          fullName: 'Unknown',
                          email: '',
                          profilePicture: null,
                        ),
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailCollaboration(
                            project: datum,
                            owner: null,
                          ),
                        ),
                      );
                    },
                  ),
                )
                .toList(),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _UsersTab extends StatelessWidget {
  final TextEditingController searchController;

  const _UsersTab({required this.searchController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is InitialSearchState || state is SearchCleared) {
          return _EmptyHint(
            icon: Icons.search,
            text: 'Cari user',
          );
        }

        if (state is SearchLoading) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: 5,
            itemBuilder: (_, __) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LoadingShimmer(
                width: double.infinity,
                height: 80,
                borderRadius: 12,
              ),
            ),
          );
        }

        if (state is SearchError) {
          return _ErrorView(
            message: state.message,
            onRetry: () {
              final q = searchController.text.trim();
              if (q.isNotEmpty) {
                context.read<SearchBloc>().add(SearchQuery(q));
              }
            },
          );
        }

        if (state is SearchLoaded) {
          final users = state.result.data?.users ?? [];

          if (users.isEmpty) {
            return _EmptyHint(
              icon: Icons.search_off,
              text: 'Tidak ada user untuk "${searchController.text}"',
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: users
                .map(
                  (user) => SearchUserCard(
                    user: user,
                    onTap: () {
                      final userId = user.id ?? user.userId ?? user.idPengguna ?? 0;
                      if (userId == 0) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserDetailViewScreen(userId: userId),
                        ),
                      );
                    },
                  ),
                )
                .toList(),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyHint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: ColorValue.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: ColorValue.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: ColorValue.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

class _SearchContent extends StatefulWidget {
  final TextEditingController searchController;
  final TabController tabController;

  const _SearchContent({
    required this.searchController,
    required this.tabController,
  });

  @override
  State<_SearchContent> createState() => _SearchContentState();
}

class _SearchContentState extends State<_SearchContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SizedBox(
            height: 50,
            child: TextField(
              controller: widget.searchController,
              onChanged: (query) {
                final trimmed = query.trim();
                if (trimmed.isEmpty) {
                  context.read<SearchBloc>().add(ClearSearch());
                } else {
                  context.read<SearchBloc>().add(SearchQuery(trimmed));
                }
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Cari User atau Proyek',
                hintStyle: const TextStyle(
                  color: ColorValue.textSecondary,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: ColorValue.textSecondary,
                  size: 20,
                ),
                suffixIcon: widget.searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          widget.searchController.clear();
                          context.read<SearchBloc>().add(ClearSearch());
                          setState(() {});
                        },
                        icon: const Icon(
                          Icons.close,
                          color: ColorValue.textSecondary,
                          size: 20,
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: ColorValue.borderColor,
                    width: 1.2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: ColorValue.borderColor,
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF2F80ED),
                    width: 1.4,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ),
        TabBar(
          controller: widget.tabController,
          labelColor: ColorValue.primaryColor,
          unselectedLabelColor: ColorValue.textSecondary,
          indicatorColor: ColorValue.primaryColor,
          tabs: const [
            Tab(text: 'Proyek'),
            Tab(text: 'User'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: widget.tabController,
            children: [
              _ProjectsTab(searchController: widget.searchController),
              _UsersTab(searchController: widget.searchController),
            ],
          ),
        ),
      ],
    );
  }
}

