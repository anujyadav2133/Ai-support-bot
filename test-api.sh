#!/bin/bash

# AI Support Bot - Quick Test Script
# This script tests all major API endpoints

API_BASE="http://localhost:4000/api"

echo "🤖 AI Support Bot - API Test Script"
echo "===================================="
echo ""

# Check if server is running
echo "📡 Checking server health..."
HEALTH=$(curl -s $API_BASE/../health)
if [ $? -eq 0 ]; then
    echo "✅ Server is running"
    echo "$HEALTH" | jq .
else
    echo "❌ Server is not running. Start it with: cd backend && npm run dev"
    exit 1
fi
echo ""

# Test 1: Create Session
echo "🔵 Test 1: Create Session"
SESSION=$(curl -s -X POST $API_BASE/sessions/create \
  -H "Content-Type: application/json" \
  -d '{"metadata": {"test": "automated"}}' | jq -r '.sessionId')

if [ -n "$SESSION" ]; then
    echo "✅ Session created: $SESSION"
else
    echo "❌ Failed to create session"
    exit 1
fi
echo ""

# Test 2: Send Message
echo "🔵 Test 2: Send Message (FAQ Test)"
RESPONSE=$(curl -s -X POST $API_BASE/messages/send \
  -H "Content-Type: application/json" \
  -d "{\"sessionId\": \"$SESSION\", \"message\": \"How do I reset my password?\"}")

echo "$RESPONSE" | jq .
echo ""

# Test 3: Contextual Follow-up
echo "🔵 Test 3: Contextual Follow-up"
RESPONSE=$(curl -s -X POST $API_BASE/messages/send \
  -H "Content-Type: application/json" \
  -d "{\"sessionId\": \"$SESSION\", \"message\": \"What if I don't get the email?\"}")

echo "$RESPONSE" | jq -r '.reply'
echo ""

# Test 4: Get Messages
echo "🔵 Test 4: Get Session Messages"
MESSAGES=$(curl -s $API_BASE/messages/$SESSION)
MESSAGE_COUNT=$(echo "$MESSAGES" | jq 'length')
echo "✅ Message count: $MESSAGE_COUNT"
echo ""

# Test 5: Escalation Test
echo "🔵 Test 5: Escalation Detection"
SESSION2=$(curl -s -X POST $API_BASE/sessions/create \
  -H "Content-Type: application/json" -d '{}' | jq -r '.sessionId')

ESCALATION=$(curl -s -X POST $API_BASE/messages/send \
  -H "Content-Type: application/json" \
  -d "{\"sessionId\": \"$SESSION2\", \"message\": \"I want to speak to a human agent!\"}")

ESCALATED=$(echo "$ESCALATION" | jq -r '.escalated')
if [ "$ESCALATED" = "true" ]; then
    echo "✅ Escalation detected successfully"
else
    echo "⚠️  Escalation not detected (expected: true, got: $ESCALATED)"
fi
echo ""

# Test 6: Get Escalations
echo "🔵 Test 6: Get Escalations"
ESCALATIONS=$(curl -s $API_BASE/escalations/session/$SESSION2)
ESC_COUNT=$(echo "$ESCALATIONS" | jq 'length')
echo "✅ Escalation count for session: $ESC_COUNT"
echo ""

# Test 7: Session Summary
# echo "🔵 Test 7: Session Summary"
# SUMMARY=$(curl -s $API_BASE/sessions/$SESSION/summary)
# echo "$SUMMARY" | jq '{sessionId, messageCount, userMessageCount, escalationCount}'
# echo ""

# # Test 8: AI Summary
# echo "🔵 Test 8: AI-Generated Summary"
# AI_SUMMARY=$(curl -s -X POST $API_BASE/sessions/$SESSION/ai-summary)
# echo "$AI_SUMMARY" | jq -r '.summary'
# echo ""

# # Test 9: Next Actions
# echo "🔵 Test 9: AI Next Actions"
# ACTIONS=$(curl -s -X POST $API_BASE/sessions/$SESSION/next-actions)
# echo "$ACTIONS" | jq -r '.suggestedActions'
# echo ""

# Test 10: Get FAQs
echo "🔵 Test 10: Get FAQs"
FAQS=$(curl -s $API_BASE/faqs)
FAQ_COUNT=$(echo "$FAQS" | jq 'length')
echo "✅ Total FAQs: $FAQ_COUNT"
echo ""

# Test 11: FAQs by Category
echo "🔵 Test 11: FAQs by Category (billing)"
BILLING_FAQS=$(curl -s "$API_BASE/faqs?category=billing")
BILLING_COUNT=$(echo "$BILLING_FAQS" | jq 'length')
echo "✅ Billing FAQs: $BILLING_COUNT"
echo ""

# Summary
echo "=================================="
echo "🎉 All tests completed!"
echo ""
echo "Test Sessions Created:"
echo "  - Session 1: $SESSION"
echo "  - Session 2: $SESSION2"
echo ""
echo "You can view these sessions at:"
echo "  curl $API_BASE/sessions/$SESSION"
echo ""
