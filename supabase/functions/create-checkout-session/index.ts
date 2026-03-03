import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import Stripe from 'https://esm.sh/stripe@14.21.0'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { priceId, productId, tokenAmount, successUrl, cancelUrl, userId } = await req.json()

    if (!priceId && !productId && !tokenAmount) {
      return new Response(
        JSON.stringify({ error: 'Price ID, Product ID, or token amount is required' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
      )
    }

    // Create Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    // Get user data
    const {
      data: { user },
      error: userError,
    } = await supabaseClient.auth.getUser()

    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 401 }
      )
    }

    // Initialize Stripe
    const stripeSecretKey = Deno.env.get('STRIPE_SECRET_KEY');
    if (!stripeSecretKey) {
      console.error('STRIPE_SECRET_KEY is not set');
      return new Response(
        JSON.stringify({ error: 'Server configuration error' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
      )
    }

    const stripe = new Stripe(stripeSecretKey, {
      apiVersion: '2023-10-16',
    })

    // Create checkout session parameters
    let sessionParams: any = {
      customer_email: user.email,
      billing_address_collection: 'auto',
      mode: 'payment',
      success_url: successUrl || `${req.headers.get('origin')}/success`,
      cancel_url: cancelUrl || `${req.headers.get('origin')}/cancel`,
      metadata: {
        userId: userId || user.id, // Use provided userId or fallback to authenticated user
        token_amount: tokenAmount?.toString() || '0', // Add token amount to metadata
      },
    }

    // Handle different payment types
    if (tokenAmount) {
      // Direct token purchase
      sessionParams.line_items = [
        {
          price_data: {
            currency: 'usd',
            product_data: { name: `${tokenAmount} Tokens` },
            unit_amount: tokenAmount * 100, // $1 per token
          },
          quantity: 1,
        },
      ]
      sessionParams.metadata.token_amount = tokenAmount.toString()
    } else if (productId) {
      // Fetch price for product
      const prices = await stripe.prices.list({ product: productId, active: true, limit: 1 });
      if (prices.data.length === 0) {
        throw new Error(`No active prices found for product ${productId}`);
      }
      sessionParams.line_items = [
        {
          price: prices.data[0].id,
          quantity: 1,
        },
      ]
      sessionParams.metadata.product_id = productId;
      // If it's the specific product for activation, we might want to flag it
      if (productId === 'prod_U06aN1WnzDJNRspk') {
        sessionParams.metadata.is_activation = 'true';
        sessionParams.metadata.token_amount = '1000'; // Default 1000 tokens for activation product
      }
    } else {
      // Price ID based purchase
      sessionParams.line_items = [
        {
          price: priceId,
          quantity: 1,
        },
      ]
      sessionParams.metadata.price_id = priceId
    }

    // Create Stripe checkout session
    const session = await stripe.checkout.sessions.create(sessionParams)

    // Store session in database
    const { data: sessionData, error: insertError } = await supabaseClient
      .from('checkout_sessions')
      .insert({
        user_id: user.id,
        price_id: priceId || productId || `tokens_${tokenAmount}`,
        stripe_session_id: session.id,
        success_url: successUrl || `${req.headers.get('origin')}/success`,
        cancel_url: cancelUrl || `${req.headers.get('origin')}/cancel`,
        status: 'pending',
      })
      .select()
      .single()

    if (insertError) {
      console.error('Error storing session:', insertError)
    }

    return new Response(
      JSON.stringify({
        sessionId: session.id,
        url: session.url,
        sessionData: sessionData
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    )
  } catch (error) {
    console.error('Error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
    )
  }
})

