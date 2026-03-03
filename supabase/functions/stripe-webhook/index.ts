import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import Stripe from 'https://esm.sh/stripe@14.21.0'

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY') || '', {
  apiVersion: '2026-01-28.clover',
})

const supabase = createClient(
  Deno.env.get('SUPABASE_URL') || '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || ''
)

serve(async (req) => {
  const signature = req.headers.get('stripe-signature')
  const body = await req.text()
  const endpointSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET') || 'whsec_iABKQStqF14xZWYUHCMaZkPQ2rCLTbZG'

  console.log(`🔑 Webhook secret length: ${endpointSecret.length}`)
  console.log(`🔑 Webhook secret first 10 chars: ${endpointSecret.substring(0, 10)}...`)
  console.log(`🔑 Full webhook secret: ${endpointSecret}`)
  console.log(`📝 Signature: ${signature ? signature.substring(0, 20) + '...' : 'MISSING'}`)
  console.log(`📄 Body length: ${body.length}`)

  // If no signature header, it's likely from Stripe CLI forwarding
  if (!signature) {
    console.log('⚠️ No stripe-signature header found - likely from Stripe CLI forward')
    console.log('🔧 Processing without signature verification (CLI mode)')
    
    try {
      const event = JSON.parse(body) as Stripe.Event
      console.log(`🔔 Event received: ${event.type}`)

      // Handle different event types
      switch (event.type) {
        case 'checkout.session.completed':
          await handleCheckoutSessionCompleted(event.data.object as Stripe.Checkout.Session)
          break
        
        case 'payment_intent.succeeded':
          console.log('💳 Payment intent succeeded - no action needed for tokens')
          break
        
        case 'charge.succeeded':
          console.log('💰 Charge succeeded - no action needed for tokens')
          break
        
        case 'product.created':
        case 'price.created':
          console.log('📦 Product/Price created - no action needed')
          break
        
        default:
          console.log(`ℹ️ Unhandled event type: ${event.type}`)
      }

      return new Response(JSON.stringify({ received: true, mode: 'cli-forward' }), {
        headers: { 'Content-Type': 'application/json' },
        status: 200,
      })
    } catch (err: any) {
      console.error('❌ Failed to process webhook:', err.message)
      return new Response('Invalid JSON', { status: 400 })
    }
  }

  // TEMPORARILY DISABLE SIGNATURE VERIFICATION FOR TESTING
  console.log('🔧 Signature verification disabled for testing')
  const event = JSON.parse(body) as Stripe.Event
  console.log(`🔔 Event received: ${event.type}`)

  // Handle different event types
  switch (event.type) {
    case 'checkout.session.completed':
      await handleCheckoutSessionCompleted(event.data.object as Stripe.Checkout.Session)
      break
    
    case 'payment_intent.succeeded':
      console.log('💳 Payment intent succeeded - no action needed for tokens')
      break
    
    case 'charge.succeeded':
      console.log('💰 Charge succeeded - no action needed for tokens')
      break
    
    case 'product.created':
    case 'price.created':
      console.log('📦 Product/Price created - no action needed')
      break
    
    default:
      console.log(`ℹ️ Unhandled event type: ${event.type}`)
  }

  return new Response(JSON.stringify({ received: true, verification: 'disabled' }), {
    headers: { 'Content-Type': 'application/json' },
    status: 200,
  })
})

async function handleCheckoutSessionCompleted(session: Stripe.Checkout.Session) {
  const userId = session.metadata?.userId
  const tokenAmount = parseInt(session.metadata?.token_amount || '0')
  const sessionId = session.id

  if (!userId || !tokenAmount) {
    console.error('❌ Missing metadata')
    throw new Error('Missing metadata')
  }

  // 🔒 IDEMPOTENCY CHECK (Prevents duplicate credit)
  const { data: existing } = await supabase
    .from('token_ledger')
    .select('id')
    .eq('reference_id', sessionId)
    .maybeSingle()

  if (existing) {
    console.log('⚠️ Session already processed')
    return
  }

  console.log(`💰 Crediting ${tokenAmount} tokens to user ${userId}`)

  // Get wallet
  const { data: wallet, error: walletError } = await supabase
    .from('wallets')
    .select('id')
    .eq('user_id', userId)
    .single()

  if (walletError || !wallet) {
    console.error('❌ Wallet not found:', walletError)
    throw new Error('Wallet not found')
  }

  // Insert ledger entry
  const { error: insertError } = await supabase
    .from('token_ledger')
    .insert({
      wallet_id: wallet.id,
      entry_type: 'credit',
      amount: tokenAmount,
      description: `Purchased ${tokenAmount} tokens via Stripe`,
      reference_id: sessionId,
    })

  if (insertError) {
    console.error('❌ Failed to insert ledger:', insertError)
    throw new Error('Insert failed')
  }

  console.log('✅ Tokens credited successfully')
}

export const config = {
  verify_jwt: false, // 🔥 REQUIRED for Stripe
}