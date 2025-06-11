# 🧪 **EXTRAS SYSTEM TESTING & DEBUG GUIDE**

## 🚀 **QUICK START TESTING**

### **Method 1: Debug Button (Easiest)**
1. **Run the app**: `flutter run`
2. **Navigate to Menu screen**
3. **Tap the bug icon** (🐛) in the top-right corner
4. **Select testing option**:
   - **Extras Test Screen** - Basic validation
   - **Extras Demo Screen** - Full experience
   - **Test Sandwich Extras** - Direct test

### **Method 2: Direct Navigation**
```dart
// Add to any screen for quick access
Navigator.push(context, MaterialPageRoute(
  builder: (context) => ExtrasTestScreen(),
));
```

### **Method 3: Menu Flow Testing**
1. **Go to Menu** → **Sandwiches**
2. **Select "The OG Sando"** or **"Sweet Heat Sando"**
3. **Tap "Add to Cart"** - Extras screen should appear
4. **Test all features**

---

## 🔍 **TESTING CHECKLIST**

### **✅ Basic Functionality**
- [ ] Menu extras data loads correctly
- [ ] Extras screen opens for eligible items
- [ ] Price calculation works in real-time
- [ ] Cart integration functions properly
- [ ] Special instructions save correctly

### **✅ User Interface**
- [ ] Sections display properly (Combo, Extras)
- [ ] Quantity controls work (+/- buttons)
- [ ] Popular badges show correctly
- [ ] Price updates are immediate
- [ ] Navigation flows smoothly

### **✅ Cart Integration**
- [ ] Items with extras appear in cart
- [ ] Extras breakdown is visible
- [ ] Pricing includes extras correctly
- [ ] Special instructions display
- [ ] Cart totals are accurate

### **✅ Edge Cases**
- [ ] Maximum extras limit (20) enforced
- [ ] Minimum selection requirements work
- [ ] Empty extras handling
- [ ] Navigation cancellation
- [ ] Error handling

---

## 🐛 **COMMON ISSUES & FIXES**

### **Issue: Extras screen doesn't appear**
**Cause**: Menu item doesn't have `allowsExtras: true`
**Fix**: 
```dart
MenuItem(
  // ... other properties
  allowsExtras: true, // Add this
)
```

### **Issue: No extras available**
**Cause**: Category not configured in `MenuExtrasData`
**Fix**: Check `MenuExtrasData.getExtrasForCategory()` method

### **Issue: Price calculation wrong**
**Cause**: Cart service not including extras price
**Fix**: Verify `CartItem.itemPrice` includes `extras.totalExtrasPrice`

### **Issue: Cart doesn't show extras**
**Cause**: Cart screen not updated for extras display
**Fix**: Check cart screen extras display section

### **Issue: Navigation errors**
**Cause**: Missing imports or route issues
**Fix**: Verify all imports and navigation paths

---

## 📊 **DEBUG INFORMATION**

### **Key Files to Check**
```
lib/models/menu_extras.dart          - Core extras models
lib/screens/menu_item_extras_screen.dart - Main extras UI
lib/screens/extras_test_screen.dart  - Testing interface
lib/services/cart_service.dart       - Cart integration
lib/models/cart.dart                 - Cart models
```

### **Debug Commands**
```dart
// Test extras data
final extras = MenuExtrasData.getExtrasForCategory('sandwiches');
print('Extras sections: ${extras.length}');

// Test cart integration
final cartItems = cartService.getCartItems();
print('Cart items: ${cartItems.length}');

// Test price calculation
final totalPrice = cartService.getTotalPrice();
print('Total price: \$${totalPrice.toStringAsFixed(2)}');
```

### **Logging Points**
- Menu item creation with extras flag
- Extras screen navigation
- Price calculations
- Cart additions
- Error conditions

---

## 🧪 **MANUAL TESTING SCENARIOS**

### **Scenario 1: Basic Extras Addition**
1. Open sandwich with extras
2. Add "Make it a Combo!" (+$8.50)
3. Add 2-3 sauce extras (+$1.50 each)
4. Add special instructions
5. Verify total price calculation
6. Add to cart and check display

### **Scenario 2: Maximum Extras Test**
1. Open any item with extras
2. Try to add 20+ extras
3. Verify limit enforcement
4. Check UI feedback

### **Scenario 3: Cart Integration Test**
1. Add multiple items with different extras
2. Check cart displays all extras correctly
3. Verify individual and total pricing
4. Test cart editing/removal

### **Scenario 4: Navigation Flow Test**
1. Test canceling extras selection
2. Test back navigation
3. Test app state preservation
4. Test multiple item additions

---

## 📈 **PERFORMANCE TESTING**

### **Load Testing**
- Add 10+ items with extras to cart
- Test scroll performance in extras screen
- Check memory usage with large extras lists
- Verify smooth animations

### **Responsiveness Testing**
- Test on different screen sizes
- Verify mobile/tablet layouts
- Check touch target sizes
- Test keyboard navigation

---

## 🔧 **DEVELOPMENT TOOLS**

### **Flutter Inspector**
- Check widget tree structure
- Verify state management
- Monitor rebuilds

### **Debug Console**
- Watch for error messages
- Monitor navigation events
- Check data flow

### **Hot Reload Testing**
- Test code changes instantly
- Verify state preservation
- Check UI updates

---

## 📞 **SUPPORT & TROUBLESHOOTING**

### **If Tests Fail**
1. **Check Flutter version**: Ensure compatible version
2. **Clean build**: Run `flutter clean && flutter pub get`
3. **Check dependencies**: Verify all packages installed
4. **Review logs**: Check console for error messages
5. **Test incrementally**: Start with basic tests first

### **Getting Help**
- Use the debug menu for quick diagnostics
- Check the test screen for system status
- Review implementation documentation
- Test with sample data first

---

**🎯 The extras system is designed to be robust and user-friendly. Follow this testing guide to ensure everything works perfectly in your environment!**
