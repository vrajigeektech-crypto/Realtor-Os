/**
 * lead-classify — AI-powered lead classification using GPT-4o-mini.
 *
 * POST body:
 *   { contacts: LeadInput[] }   (max 50 per call)
 *
 * Response:
 *   { results: ClassificationResult[] }  (same order as input)
 *
 * Set the OPENAI_API_KEY secret via:
 *   supabase secrets set OPENAI_API_KEY=sk-...
 */

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
};

// ─────────────────────────────────────────────────────────────────────────────
//  Types
// ─────────────────────────────────────────────────────────────────────────────

interface LeadInput {
  name?: string;
  stage?: string;
  tags?: string[];
  source?: string;
  emails?: Array<{ value: string }>;
  phones?: Array<{ value: string }>;
  lastActivity?: string;
  created?: string;
  notes?: string;
}

interface ClassificationResult {
  intent: string;      // "buy now" | "just browsing" | "researching" | "selling" | "renting" | "spam"
  urgency: string;     // "high" | "medium" | "low"
  budget: string;      // extracted budget string or "unknown"
  category: string;    // "buyer" | "seller" | "renter" | "investor" | "unknown"
  bucket: string;      // "hot" | "warm" | "cold" | "junk"
  confidence: number;  // 0–100
  reason: string;      // one-sentence explanation
}

// ─────────────────────────────────────────────────────────────────────────────
//  Handler
// ─────────────────────────────────────────────────────────────────────────────

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const OPENAI_KEY = Deno.env.get('OPENAI_API_KEY');
    if (!OPENAI_KEY) {
      console.warn('⚠️ [lead-classify] OPENAI_API_KEY not set — using fallback');
      const { contacts } = await req.json() as { contacts: LeadInput[] };
      const results = contacts.map(fallbackClassify);
      return json({ results });
    }

    const { contacts } = await req.json() as { contacts: LeadInput[] };
    if (!Array.isArray(contacts) || contacts.length === 0) {
      return json({ results: [] });
    }

    // Cap at 50 contacts per call to stay within timeout.
    const batch = contacts.slice(0, 50);
    const results: ClassificationResult[] = [];

    for (const contact of batch) {
      try {
        const result = await classifyWithAI(contact, OPENAI_KEY);
        results.push(result);
      } catch (err) {
        console.error('⚠️ [lead-classify] AI error for contact, using fallback:', err);
        results.push(fallbackClassify(contact));
      }
    }

    console.log(`✅ [lead-classify] Classified ${results.length} contacts`);
    return json({ results });
  } catch (err) {
    console.error('❌ [lead-classify] Unhandled error:', err);
    return json({ error: String(err) }, 500);
  }
});

// ─────────────────────────────────────────────────────────────────────────────
//  AI classification
// ─────────────────────────────────────────────────────────────────────────────

async function classifyWithAI(
  contact: LeadInput,
  apiKey: string,
): Promise<ClassificationResult> {
  const summary = buildSummary(contact);

  const systemPrompt = `You are an expert real estate lead classifier. 
Classify each lead into exactly one bucket using these rules:

🔥 HOT  — intent is "buy now" or "sell now", high urgency, recently active (≤30 days), motivated
🌤 WARM — interested but not urgent, nurturing phase, active 30-365 days ago, long-term plans
❄️ COLD — just browsing, no urgency, inactive >1 year, unresponsive
🚫 JUNK — spam, fake data, no contact info, DNC, test entries

Additional guidance:
- If a lead has NO email AND NO phone → always JUNK
- If stage/tag says "dead", "removed", "spam", "dnc" → JUNK
- If stage says "hot", "active", "under contract", "showing" → HOT
- If stage says "nurture", "long term", "6 months", "future" → WARM
- Extract budget if mentioned (e.g. "80L", "$500k", "under 400k"), else "unknown"
- Category: buyer, seller, renter, investor, or unknown`;

  const userPrompt = `Classify this real estate lead:

${summary}

Respond ONLY with valid JSON matching this exact schema (no markdown, no explanation outside JSON):
{
  "intent": "buy now" | "just browsing" | "researching" | "selling" | "renting" | "spam",
  "urgency": "high" | "medium" | "low",
  "budget": "<extracted budget or 'unknown'>",
  "category": "buyer" | "seller" | "renter" | "investor" | "unknown",
  "bucket": "hot" | "warm" | "cold" | "junk",
  "confidence": <integer 0-100>,
  "reason": "<one clear sentence explaining the classification>"
}`;

  const response = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: 'gpt-4o-mini',
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: userPrompt },
      ],
      temperature: 0,
      max_tokens: 256,
      response_format: { type: 'json_object' },
    }),
  });

  if (!response.ok) {
    const errText = await response.text();
    throw new Error(`OpenAI API error ${response.status}: ${errText}`);
  }

  const data = await response.json();
  const content = data.choices?.[0]?.message?.content;
  if (!content) throw new Error('Empty response from OpenAI');

  const result = JSON.parse(content) as ClassificationResult;

  // Validate required fields and apply safety defaults.
  return {
    intent: result.intent || 'unknown',
    urgency: result.urgency || 'medium',
    budget: result.budget || 'unknown',
    category: result.category || 'unknown',
    bucket: validateBucket(result.bucket),
    confidence: clamp(Number(result.confidence) || 60, 0, 100),
    reason: result.reason || 'AI classified',
  };
}

// ─────────────────────────────────────────────────────────────────────────────
//  Rule-based fallback (no OpenAI key or API failure)
// ─────────────────────────────────────────────────────────────────────────────

function fallbackClassify(c: LeadInput): ClassificationResult {
  const stage = (c.stage ?? '').toLowerCase();
  const tagsStr = (c.tags ?? []).join(' ').toLowerCase();
  const hasEmail = (c.emails?.length ?? 0) > 0;
  const hasPhone = (c.phones?.length ?? 0) > 0;

  // Junk: no contact info
  if (!hasEmail && !hasPhone) {
    return mk('spam', 'low', 'unknown', 'unknown', 'junk', 75,
      'No email or phone on file');
  }

  // Junk: explicit junk signals
  if (/dead|removed|spam|dnc|fake|test/.test(stage) ||
    /dead|spam|dnc|remove|fake|junk/.test(tagsStr)) {
    return mk('spam', 'low', 'unknown', 'unknown', 'junk', 80,
      'Stage or tag indicates junk/spam');
  }

  // Hot: hot stage/tag or recent activity
  if (/hot|active|showing|offer|contract|closing|ready|pre-approved|pipeline/.test(stage) ||
    /hot|urgent|buy now|motivated|ready/.test(tagsStr)) {
    const cat = /sell/.test(tagsStr) ? 'seller' : 'buyer';
    return mk('buy now', 'high', 'unknown', cat, 'hot', 70,
      'Hot stage or urgent tag detected');
  }

  // Cold: explicit cold/dead stage
  if (/cold|inactive|lost|closed|not interested|unresponsive/.test(stage) ||
    /cold|not interested|no response|inactive/.test(tagsStr)) {
    return mk('just browsing', 'low', 'unknown', 'unknown', 'cold', 68,
      'Cold or inactive stage');
  }

  // Days since last activity
  let daysSince: number | null = null;
  const actRaw = c.lastActivity;
  if (actRaw) {
    daysSince = Math.floor((Date.now() - new Date(actRaw).getTime()) / 86_400_000);
  }
  if (daysSince !== null && daysSince > 365) {
    return mk('just browsing', 'low', 'unknown', 'unknown', 'cold', 65,
      'No activity for over a year');
  }

  // Default → warm
  const cat2 = /sell/.test(tagsStr) ? 'seller' : /rent/.test(tagsStr) ? 'renter' : 'buyer';
  return mk('researching', 'medium', 'unknown', cat2, 'warm', 50,
    'No strong signals — placed in warm nurture bucket');
}

// ─────────────────────────────────────────────────────────────────────────────
//  Utilities
// ─────────────────────────────────────────────────────────────────────────────

function buildSummary(c: LeadInput): string {
  const lines: string[] = [];
  if (c.name) lines.push(`Name: ${c.name}`);
  if (c.stage) lines.push(`Stage: ${c.stage}`);
  if (c.tags?.length) lines.push(`Tags: ${c.tags.join(', ')}`);
  if (c.source) lines.push(`Source: ${c.source}`);
  lines.push(`Has email: ${(c.emails?.length ?? 0) > 0 ? 'yes' : 'no'}`);
  lines.push(`Has phone: ${(c.phones?.length ?? 0) > 0 ? 'yes' : 'no'}`);
  if (c.lastActivity) {
    const days = Math.floor(
      (Date.now() - new Date(c.lastActivity).getTime()) / 86_400_000,
    );
    lines.push(`Last activity: ${days} day(s) ago`);
  }
  if (c.created) {
    const daysCreated = Math.floor(
      (Date.now() - new Date(c.created).getTime()) / 86_400_000,
    );
    lines.push(`Lead age: ${daysCreated} day(s)`);
  }
  if (c.notes) lines.push(`Notes: ${c.notes.slice(0, 300)}`);
  return lines.join('\n') || 'No data provided';
}

function validateBucket(b: string): string {
  return ['hot', 'warm', 'cold', 'junk'].includes(b) ? b : 'cold';
}

function clamp(n: number, min: number, max: number): number {
  return Math.max(min, Math.min(max, n));
}

function mk(
  intent: string, urgency: string, budget: string, category: string,
  bucket: string, confidence: number, reason: string,
): ClassificationResult {
  return { intent, urgency, budget, category, bucket, confidence, reason };
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}
