# Quick Start Guide

Get the AI Support Bot running in 5 minutes!

## 🚀 Fast Setup

### Step 1: Install Dependencies
```bash
cd backend
npm install
```

### Step 2: Configure API Key
```bash
# Copy the example env file
cp .env.example .env

# Edit .env and add your Gemini API key
# Get a free API key from: https://makersuite.google.com/app/apikey
```

Edit `.env`:
```env
GEMINI_API_KEY=your_actual_key_here
```

### Step 3: Start Server
```bash
npm run dev
```

You should see:
```
Database tables initialized.
Seeded 8 FAQs into database.
SQLite DB loaded from: ./data/db.sqlite
AI Support backend running on port 4000
```

## ✅ Verify It's Working

### Option 1: Web Interface (Easiest)

1. Open `frontend/index.html` in your browser
2. Type: "How do I reset my password?"
3. You should get a helpful AI response!

### Option 2: curl Test

```bash
# Create a session
curl -X POST http://localhost:4000/api/sessions/create \
  -H "Content-Type: application/json" \
  -d '{}'

# Copy the sessionId from response, then:
curl -X POST http://localhost:4000/api/messages/send \
  -H "Content-Type: application/json" \
  -d '{"sessionId":"YOUR_SESSION_ID","message":"How do I reset my password?"}'
```

### Option 3: Automated Test Script

```bash
cd ..  # Go to project root
chmod +x test-api.sh
./test-api.sh
```

## 🎯 Quick Feature Tour

### 1. Ask a Question
```bash
SESSION=$(curl -s -X POST http://localhost:4000/api/sessions/create \
  -H "Content-Type: application/json" -d '{}' | jq -r '.sessionId')

curl -X POST http://localhost:4000/api/messages/send \
  -H "Content-Type: application/json" \
  -d "{\"sessionId\":\"$SESSION\",\"message\":\"What's your refund policy?\"}" | jq
```

### 2. Trigger Escalation
```bash
curl -X POST http://localhost:4000/api/messages/send \
  -H "Content-Type: application/json" \
  -d "{\"sessionId\":\"$SESSION\",\"message\":\"I need to speak to a human agent\"}" | jq
```

### 3. Get AI Summary
```bash
curl -X POST http://localhost:4000/api/sessions/$SESSION/ai-summary | jq
```

## 🐛 Troubleshooting

### "Missing GEMINI_API_KEY"
- Make sure you created `.env` file in the `backend/` directory
- Check that GEMINI_API_KEY is set correctly
- Restart the server after adding the key

### "Cannot POST /api/message/send"
- The endpoint is `/api/messages/send` (plural!)

### "better-sqlite3" errors
```bash
npm rebuild better-sqlite3
```

### Port 4000 already in use
```bash
# Edit .env and change PORT
PORT=5000

# Or kill the process using port 4000
lsof -ti:4000 | xargs kill
```

## 📖 Next Steps

1. **Read the full README**: `README.md` has complete API documentation
2. **Try the demo scenarios**: `DEMO.md` has detailed test workflows
3. **Learn about prompts**: `PROMPTS_DOCUMENTATION.md` explains the AI prompting
4. **Explore the code**: Start with `backend/server.js` and `backend/routes/messages.js`

## 🎥 Record a Demo Video

Follow the script in `DEMO.md` to create a compelling demo video showing:
- Web chat interface
- FAQ system
- Contextual conversations
- Escalation detection
- AI summarization
- Code walkthrough

## 📚 API Endpoints Summary

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/sessions/create` | POST | Create new chat session |
| `/api/messages/send` | POST | Send message & get AI response |
| `/api/sessions/:id/summary` | GET | Get session statistics |
| `/api/sessions/:id/ai-summary` | POST | AI-generated summary |
| `/api/escalations` | GET | List escalations |
| `/api/faqs` | GET | Get all FAQs |

Full API docs in `README.md`!

---

**Need help?** Check the troubleshooting section or review the detailed documentation.

**Ready to customize?** Edit FAQs in `backend/db.js` and prompts in `backend/prompts.js`!
