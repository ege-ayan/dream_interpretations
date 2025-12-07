import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../../services/revenue_cat_service.dart';

class SubscriptionView extends StatefulWidget {
  const SubscriptionView({super.key});

  @override
  State<SubscriptionView> createState() => _SubscriptionViewState();
}

class _SubscriptionViewState extends State<SubscriptionView> {
  final RevenueCatService _revenueCatService = RevenueCatService();
  bool _isLoading = true;
  bool _hasActiveSubscription = false;
  Offerings? _offerings;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final hasSubscription = await _revenueCatService.hasActiveSubscription();
      final offerings = await _revenueCatService.getOfferings();

      setState(() {
        _hasActiveSubscription = hasSubscription;
        _offerings = offerings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Abonelik bilgileri yüklenemedi: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _purchasePackage(Package package) async {
    setState(() => _isLoading = true);

    try {
      final success = await _revenueCatService.purchasePackage(package);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Abonelik başarıyla satın alındı!')),
          );
          _loadData();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Satın alma işlemi iptal edildi')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isLoading = true);

    try {
      final success = await _revenueCatService.restorePurchases();
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Satın alımlar geri yüklendi!')),
          );
          _loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Geri yüklenecek satın alım bulunamadı'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showPaywall() async {
    try {
      final paywallResult = await RevenueCatUI.presentPaywall();
      debugPrint('Paywall result: $paywallResult');
      // Reload after paywall dismissal
      if (mounted) {
        _loadData();
      }
    } catch (e) {
      debugPrint('Error showing paywall: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ödeme ekranı yüklenemedi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Fixed Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.menu),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Abonelik',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),
                          // Premium icon with glow
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.secondary,
                                  ],
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surface,
                                child: Icon(
                                  Icons.workspace_premium,
                                  size: 60,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Title
                          Text(
                            _hasActiveSubscription
                                ? 'Premium Üyesiniz'
                                : 'Premium Abonelik',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _hasActiveSubscription
                                ? 'Tüm premium özelliklere erişiminiz var!'
                                : 'Sınırsız rüya yorumlama ve özel özelliklerle rüyalarınızı daha derinlemesine keşfedin.',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                            textAlign: TextAlign.center,
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.orange),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                          const SizedBox(height: 48),
                          // Features
                          Column(
                            children: [
                              _buildFeature(
                                context,
                                Icons.nightlight_rounded,
                                'Sınırsız Yorumlama',
                                'İstediğiniz kadar rüyanızı yorumlayın',
                              ),
                              const SizedBox(height: 16),
                              _buildFeature(
                                context,
                                Icons.auto_awesome,
                                'Gelişmiş AI',
                                'Daha detaylı ve kişiselleştirilmiş yorumlar',
                              ),
                              const SizedBox(height: 16),
                              _buildFeature(
                                context,
                                Icons.history,
                                'Rüya Geçmişi',
                                'Tüm rüyalarınızı kaydedin ve takip edin',
                              ),
                              const SizedBox(height: 16),
                              _buildFeature(
                                context,
                                Icons.trending_up,
                                'Trend Analizi',
                                'Rüyalarınızdaki paternleri keşfedin',
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Show Paywall button (RevenueCat UI)
                          if (!_hasActiveSubscription)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: OutlinedButton.icon(
                                onPressed: _showPaywall,
                                icon: const Icon(Icons.payment),
                                label: const Text('Ödeme Ekranını Göster'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  side: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  minimumSize: const Size(double.infinity, 48),
                                ),
                              ),
                            ),
                          // Subscription packages or active status
                          if (_hasActiveSubscription)
                            _buildActiveSubscriptionCard()
                          else if (_offerings
                                  ?.current
                                  ?.availablePackages
                                  .isNotEmpty ==
                              true)
                            _buildPackagesCard()
                          else
                            _buildPlaceholderCard(),
                          const SizedBox(height: 16),
                          // Restore button
                          if (!_hasActiveSubscription)
                            TextButton(
                              onPressed: _restorePurchases,
                              child: Text(
                                'Satın Alımları Geri Yükle',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildActiveSubscriptionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Premium Aktif',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagesCard() {
    final packages = _offerings!.current!.availablePackages;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ...packages.map((package) {
            final price = package.storeProduct.priceString;
            return Column(
              children: [
                Text(
                  '$price / ${package.storeProduct.subscriptionPeriod ?? "Ay"}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _purchasePackage(package),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: const Text(
                    'Premium\'a Geç',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPlaceholderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '₺99.99 / Ay',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'RevenueCat yapılandırılıyor...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).colorScheme.primary,
              minimumSize: const Size(double.infinity, 56),
            ),
            child: const Text(
              'Yakında',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
