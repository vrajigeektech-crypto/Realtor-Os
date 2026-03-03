# Checkout Session Setup and Deployment Guide

## ✅ Implementation Complete

Your Stripe checkout session has been successfully created and deployed to Supabase!

### 📋 What's Been Created

1. **Supabase Edge Function** (`create-checkout-session`)
   - Handles Stripe checkout session creation
   - Supports both token purchases and price ID based payments
   - Includes proper authentication and error handling

2. **Flutter Checkout Service** (`lib/services/checkout_service.dart`)
   - Service class for interacting with the checkout function
   - Methods for creating sessions, retrieving session history
   - Direct Stripe API integration as backup

3. **Checkout UI Screen** (`lib/screens/checkout_screen.dart`)
   - Beautiful checkout interface for token purchases
   - Session history display
   - Loading states and error handling

4. **Database Schema** (`create_checkout_session_rpc.sql`)
   - `checkout_sessions` table for tracking payments
   - `app_secrets` table for storing API keys
   - Row Level Security policies

### 🚀 How to Use

#### 1. Set Up Environment Variables

In your Supabase dashboard, add these secrets:

```bash
STRIPE_SECRET_KEY=sk_test_...  # Your Stripe secret key
```

#### 2. Deploy the Edge Function

```bash
# Deploy to Supabase
supabase functions deploy create-checkout-session

# Or use the dashboard to deploy
```

#### 3. Update Your Flutter App

Add the checkout screen to your app:

```dart
import '../screens/checkout_screen.dart';

// Navigate to checkout
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const CheckoutScreen()),
);
```

#### 4. Test the Checkout Flow

1. Run your Flutter app
2. Navigate to the checkout screen
3. Click "Buy 100 Tokens"
4. You'll be redirected to Stripe's checkout page
5. Complete the test payment

### 💳 Payment Options

The system supports:

- **Token Purchases**: Buy tokens directly (e.g., 100 tokens for $100)
- **Price ID Purchases**: Use predefined Stripe prices
- **Flexible Pricing**: $1 per token by default

### 🔧 Configuration

#### Stripe Configuration

1. Create a Stripe account if you don't have one
2. Get your API keys from the Stripe dashboard
3. Add the secret key to Supabase secrets
4. Create products/prices in Stripe if using price IDs

#### Success/Cancel URLs

Update these URLs in your checkout calls:

```dart
final session = await CheckoutService.createCheckoutSession(
  tokenAmount: 100,
  successUrl: 'https://yourapp.com/success',
  cancelUrl: 'https://yourapp.com/cancel',
);
```

### 📱 UI Features

The checkout screen includes:

- **Token Purchase Interface**: Clean, modern design
- **Session History**: View past checkout attempts
- **Status Indicators**: Visual feedback for session states
- **Loading States**: Smooth user experience
- **Error Handling**: User-friendly error messages

### 🔍 Monitoring

#### Database Tables

- `checkout_sessions`: Track all payment attempts
- `app_secrets`: Store your API keys securely

#### Session Statuses

- `pending`: Session created, awaiting payment
- `completed`: Payment successful
- `cancelled`: User cancelled the payment
- `failed`: Payment failed

### 🛡️ Security Features

- **Authentication**: Only logged-in users can create sessions
- **Row Level Security**: Users can only see their own sessions
- **Environment Variables**: API keys stored securely
- **CORS Protection**: Proper headers for web security

### 🔄 Next Steps

1. **Webhook Setup**: Configure Stripe webhooks to handle payment events
2. **Token Balance**: Implement token balance tracking
3. **Subscription Plans**: Add recurring payment options
4. **Analytics**: Track conversion rates and revenue

### 🐛 Troubleshooting

#### Common Issues

1. **Docker Not Running**: Start Docker Desktop for local development
2. **Missing Secrets**: Add STRIPE_SECRET_KEY to Supabase
3. **CORS Errors**: Ensure proper headers in the Edge Function
4. **Authentication**: Ensure user is logged in before checkout

#### Debug Mode

Enable debug logging:

```dart
// In checkout service
print('Debug: Creating session for user ${user.id}');
```

### 📞 Support

If you encounter issues:

1. Check Supabase function logs
2. Verify Stripe API keys
3. Test with Stripe's test mode
4. Review database permissions

---

**Your checkout system is ready! 🎉**
