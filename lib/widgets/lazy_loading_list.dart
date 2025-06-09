import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/api_service.dart';

/// 🔄 Lazy Loading List Widget with Pagination
/// Efficiently loads and displays large lists of data
class LazyLoadingList<T> extends StatefulWidget {
  final Future<List<T>> Function(int page, int limit) loadData;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final int itemsPerPage;
  final ScrollController? scrollController;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const LazyLoadingList({
    Key? key,
    required this.loadData,
    required this.itemBuilder,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.itemsPerPage = 20,
    this.scrollController,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  }) : super(key: key);

  @override
  State<LazyLoadingList<T>> createState() => _LazyLoadingListState<T>();
}

class _LazyLoadingListState<T> extends State<LazyLoadingList<T>> {
  final List<T> _items = [];
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = false;
  bool _hasMoreData = true;
  bool _hasError = false;
  String? _errorMessage;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    
    // Use provided controller or create new one
    final controller = widget.scrollController ?? _scrollController;
    
    // Add scroll listener for pagination
    controller.addListener(_onScroll);
    
    // Load initial data
    _loadInitialData();
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  /// 📱 Handle scroll events for pagination
  void _onScroll() {
    final controller = widget.scrollController ?? _scrollController;
    
    if (controller.position.pixels >= controller.position.maxScrollExtent - 200) {
      // Load more data when user is 200px from bottom
      _loadMoreData();
    }
  }

  /// 🔄 Load initial data
  Future<void> _loadInitialData() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final newItems = await widget.loadData(1, widget.itemsPerPage);
      
      setState(() {
        _items.clear();
        _items.addAll(newItems);
        _currentPage = 1;
        _hasMoreData = newItems.length >= widget.itemsPerPage;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _hasError = true;
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  /// ➕ Load more data for pagination
  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMoreData) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final newItems = await widget.loadData(_currentPage + 1, widget.itemsPerPage);
      
      setState(() {
        _items.addAll(newItems);
        _currentPage++;
        _hasMoreData = newItems.length >= widget.itemsPerPage;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      
      // Show error snackbar for pagination errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load more items: ${error.toString()}'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadMoreData,
            ),
          ),
        );
      }
    }
  }

  /// 🔄 Refresh data
  Future<void> _refreshData() async {
    await _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    // Show error widget if initial load failed
    if (_hasError && _items.isEmpty) {
      return widget.errorWidget ?? _buildDefaultErrorWidget();
    }

    // Show empty widget if no items
    if (!_isLoading && _items.isEmpty) {
      return widget.emptyWidget ?? _buildDefaultEmptyWidget();
    }

    // Show loading widget if initial load
    if (_isLoading && _items.isEmpty) {
      return widget.loadingWidget ?? _buildDefaultLoadingWidget();
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        controller: widget.scrollController ?? _scrollController,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics,
        itemCount: _items.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          // Show loading indicator at the end
          if (index >= _items.length) {
            return _buildPaginationLoadingWidget();
          }

          // Build item widget
          return widget.itemBuilder(context, _items[index], index);
        },
      ),
    );
  }

  /// 🔄 Default loading widget
  Widget _buildDefaultLoadingWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }

  /// ❌ Default error widget
  Widget _buildDefaultErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load data',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadInitialData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// 📭 Default empty widget
  Widget _buildDefaultEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No items found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'There are no items to display at the moment.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  /// ⏳ Pagination loading widget
  Widget _buildPaginationLoadingWidget() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }
}

/// 🍽️ Menu Items Lazy Loading List
class MenuItemsLazyList extends StatelessWidget {
  final String categoryId;
  final Widget Function(BuildContext context, MenuItem item, int index)? itemBuilder;

  const MenuItemsLazyList({
    Key? key,
    required this.categoryId,
    this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LazyLoadingList<MenuItem>(
      loadData: (page, limit) => _loadMenuItems(page, limit),
      itemBuilder: itemBuilder ?? _defaultMenuItemBuilder,
      itemsPerPage: 15,
      padding: const EdgeInsets.all(16),
    );
  }

  /// 📊 Load menu items with pagination
  Future<List<MenuItem>> _loadMenuItems(int page, int limit) async {
    final apiService = ApiService();
    
    // Simulate API call with pagination
    await Future.delayed(const Duration(milliseconds: 500));
    
    // In real implementation, this would call:
    // return await apiService.getMenuItemsPaginated(categoryId, page, limit);
    
    // Mock data for demonstration
    return List.generate(limit, (index) {
      final itemIndex = (page - 1) * limit + index;
      return MenuItem(
        id: 'item_${categoryId}_$itemIndex',
        name: 'Menu Item $itemIndex',
        description: 'Delicious item from category $categoryId',
        price: 10.99 + (itemIndex % 5),
        imageUrl: 'assets/images/menu/placeholder.jpg',
        category: categoryId,
      );
    });
  }

  /// 🎨 Default menu item builder
  Widget _defaultMenuItemBuilder(BuildContext context, MenuItem item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(item.imageUrl),
          onBackgroundImageError: (_, __) {},
          child: const Icon(Icons.fastfood),
        ),
        title: Text(item.name),
        subtitle: Text(item.description),
        trailing: Text(
          '\$${item.price.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: () {
          // Handle item tap
        },
      ),
    );
  }
}
