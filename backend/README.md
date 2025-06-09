# 🍗 Chica's Chicken Backend API

A secure, scalable Node.js backend for the Chica's Chicken QSR ordering app.

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ 
- npm or yarn
- Firebase project
- Stripe account

### Installation

1. **Clone and navigate to backend directory**
```bash
cd backend
```

2. **Install dependencies**
```bash
npm install
```

3. **Set up environment variables**
```bash
cp .env.example .env
# Edit .env with your actual values
```

4. **Start development server**
```bash
npm run dev
```

The server will start on `http://localhost:3000`

## 🔧 Environment Setup

### Firebase Setup
1. Create a Firebase project at https://console.firebase.google.com
2. Enable Authentication and Firestore
3. Generate a service account key
4. Add the credentials to your `.env` file

### Stripe Setup
1. Create a Stripe account at https://stripe.com
2. Get your API keys from the dashboard
3. Add them to your `.env` file

## 📡 API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `GET /api/auth/profile` - Get user profile
- `PUT /api/auth/profile` - Update user profile
- `POST /api/auth/logout` - Logout user
- `DELETE /api/auth/account` - Delete account

### Menu
- `GET /api/menu/categories` - Get menu categories
- `GET /api/menu/category/:categoryId` - Get items by category
- `GET /api/menu/item/:itemId` - Get specific item
- `GET /api/menu/search` - Search menu items

### Orders
- `POST /api/orders` - Create new order
- `GET /api/orders` - Get user's orders
- `GET /api/orders/:orderId` - Get specific order
- `PUT /api/orders/:orderId/cancel` - Cancel order
- `PUT /api/orders/:orderId/status` - Update status (Admin)

### Payments
- `POST /api/payments/intent` - Create payment intent
- `POST /api/payments/confirm` - Confirm payment
- `GET /api/payments/history` - Get payment history
- `POST /api/payments/refund` - Process refund (Admin)

### Analytics (Admin only)
- `GET /api/analytics/dashboard` - Dashboard metrics
- `GET /api/analytics/sales` - Sales analytics
- `GET /api/analytics/menu-performance` - Menu performance

## 🛡️ Security Features

- **Firebase Authentication** - Secure user management
- **JWT Token Validation** - API endpoint protection
- **Rate Limiting** - Prevent API abuse
- **Input Validation** - Sanitize all inputs
- **CORS Protection** - Control cross-origin requests
- **Helmet.js** - Security headers

## 🗄️ Database Schema

### Users Collection
```javascript
{
  uid: string,
  email: string,
  name: string,
  phone: string,
  addresses: array,
  preferences: object,
  stripeCustomerId: string,
  createdAt: timestamp
}
```

### Orders Collection
```javascript
{
  orderNumber: string,
  userId: string,
  customerInfo: object,
  items: array,
  totalAmount: number,
  status: string,
  paymentIntentId: string,
  estimatedReady: timestamp,
  createdAt: timestamp
}
```

## 🧪 Testing

Run tests:
```bash
npm test
```

## 🚀 Deployment

### Google Cloud Platform
1. Install Google Cloud CLI
2. Set up your project
3. Deploy with:
```bash
gcloud app deploy
```

### Environment Variables for Production
Make sure to set all required environment variables in your production environment.

## 📊 Monitoring

- **Winston Logging** - Comprehensive logging
- **Error Tracking** - Centralized error handling
- **Performance Monitoring** - Request/response tracking

## 🔄 Development Workflow

1. Make changes to your code
2. Test locally with `npm run dev`
3. Run tests with `npm test`
4. Commit and push changes
5. Deploy to production

## 📞 Support

For issues or questions, check the logs in the `logs/` directory or contact the development team.

## 📄 License

MIT License - see LICENSE file for details.
