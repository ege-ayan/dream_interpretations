import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/dream_model.dart';
import '../../services/dream_service.dart';
import 'widgets/loading_view.dart';
import '../../services/firestore_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _dreamInputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final DreamService _dreamService = DreamService();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  String? _interpretationResult;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _dreamInputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _interpretDream() async {
    final dreamText = _dreamInputController.text.trim();
    if (dreamText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen rüyanızı yazın.')));
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _interpretationResult = null;
    });

    try {
      final interpretation = await _dreamService.interpretDream(dreamText);

      // Save to Firestore
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final dreamModel = DreamModel(
          id: '', // Will be generated
          userId: userId,
          dreamText: dreamText,
          interpretation: interpretation,
          timestamp: DateTime.now(),
          messages: [], // Not using chat messages anymore for this simple flow
        );
        await _firestoreService.saveDream(dreamModel);
      }

      if (mounted) {
        setState(() {
          _interpretationResult = interpretation;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Bir hata oluştu: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _reset() {
    setState(() {
      _interpretationResult = null;
      _errorMessage = null;
      _dreamInputController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      tooltip: 'Menü',
                    ),
                    Expanded(
                      child: Text(
                        'Rüya Yorumlat',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the left icon
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const DreamAnalysisLoadingView()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: _buildContent(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_interpretationResult != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Yorumunuz',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                MarkdownBody(
                  data: _interpretationResult!,
                  styleSheet: MarkdownStyleSheet(
                    p: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(height: 1.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            key: const ValueKey('reset_button'),
            onPressed: _reset,
            icon: const Icon(Icons.refresh),
            label: const Text('Yeni Rüya Yorumlat'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Rüyanızı Anlatın',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Detaylı bir şekilde rüyanızı yazın, yapay zeka sizin için yorumlasın.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _dreamInputController,
          focusNode: _focusNode,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: _focusNode.hasFocus
                ? ''
                : 'Örneğin: Ormanda yürüyordum, hava çok karanlıktı ve birden önüme parlak bir ışık çıktı...',
            hintStyle: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 32),
        ElevatedButton.icon(
          key: const ValueKey('interpret_button'),
          onPressed: _interpretDream,
          icon: const Icon(Icons.psychology),
          label: const Text('Yorumla'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
