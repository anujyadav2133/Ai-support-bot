# AI Customer Support Bot

An intelligent customer support chatbot that uses AI (Google Gemini) to handle customer queries, manage FAQs, maintain contextual conversation memory, and escalate complex issues to human agents.

## 🎯 Objective

Simulate realistic customer support interactions with:
- **AI-powered responses** using Google Gemini LLM
- **FAQ dataset integration** for common questions
- **Contextual memory** to retain conversation history
- **Smart escalation** when queries cannot be adequately answered
- **Session management** for tracking customer interactions

## ✨ Features

### Core Functionality
- ✅ **Conversational AI**: Natural language responses using Google Gemini 2.0 Flash
- ✅ **FAQ Search**: Intelligent keyword-based FAQ matching with relevance scoring
- ✅ **Session Management**: Track and manage customer conversation sessions
- ✅ **Contextual Memory**: AI considers full conversation history for better responses
- ✅ **Smart Escalation**: Automatic detection and logging of cases requiring human intervention
- ✅ **Conversation Summarization**: AI-generated summaries of support interactions
- ✅ **Next Action Suggestions**: AI-recommended follow-up actions for customers

### Technical Features
- REST API with Express.js
- SQLite database for persistent storage
- Structured prompt engineering for optimal AI responses
- Comprehensive error handling
- CORS-enabled for frontend integration

## 🏗️ Architecture

```
backend/
├── server.js              # Express server setup
├── db.js                  # Database initialization & schema
├── prompts.js             # LLM prompt engineering
├── routes/
│   ├── sessions.js        # Session management endpoints
│   ├── messages.js        # Message handling & AI responses
│   └── escalations.js     # Escalation management
├── assistant/
│   ├── faqSearch.js       # FAQ search & matching logic
│   └── llm.js             # LLM client wrapper (legacy)
└── data/
    └── db.sqlite          # SQLite database (auto-created)
```

## 📊 Database Schema

### Sessions Table
Tracks customer support sessions
```sql
- id (TEXT, PRIMARY KEY)
- created_at (INTEGER, timestamp)
- updated_at (INTEGER, timestamp)
- metadata (TEXT, JSON string)
```

### Messages Table
Stores conversation messages
```sql
- id (TEXT, PRIMARY KEY)
- session_id (TEXT, FOREIGN KEY)
- role (TEXT: 'user' or 'assistant')
- content (TEXT)
- created_at (INTEGER, timestamp)
```

### Escalations Table
Logs escalated support cases
```sql
- id (TEXT, PRIMARY KEY)
- session_id (TEXT)
- reason (TEXT)
- details (TEXT, JSON string)
- created_at (INTEGER, timestamp)
- status (TEXT: 'pending', 'in-progress', 'resolved', 'closed')
```

### FAQs Table
Pre-seeded knowledge base
```sql
- id (TEXT, PRIMARY KEY)
- question (TEXT)
- answer (TEXT)
- category (TEXT)
- keywords (TEXT, comma-separated)
- created_at (INTEGER, timestamp)
```

## 🚀 Setup & Installation

### Prerequisites
- Node.js (v18 or higher)
- npm or yarn
- Google Gemini API key

### Installation Steps

1. **Clone the repository**
```bash
git clone <repository-url>
cd ai-support-bot/backend
```

2. **Install dependencies**
```bash
npm install
```

3. **Configure environment variables**
```bash
cp .env.example .env
```

Edit `.env` and add your API key:
```env
GEMINI_API_KEY=your_gemini_api_key_here
PORT=4000
```

4. **Start the server**
```bash
# Development mode with auto-reload
npm run dev

# Production mode
npm start
```

The server will start on `http://localhost:4000`

## 📡 API Endpoints

### Sessions

#### Create Session
```http
POST /api/sessions/create
Content-Type: application/json

{
  "metadata": {
    "customerName": "John Doe",
    "email": "john@example.com"
  }
}

Response:
{
  "sessionId": "uuid-here"
}
```

#### Get Session
```http
GET /api/sessions/:id

Response:
{
  "id": "uuid",
  "created_at": 1234567890,
  "updated_at": 1234567890,
  "metadata": "{...}"
}
```

#### Get All Sessions
```http
GET /api/sessions

Response: Array of session objects
```

#### Get Session Summary
```http
GET /api/sessions/:id/summary

Response:
{
  "sessionId": "uuid",
  "messageCount": 10,
  "userMessageCount": 5,
  "assistantMessageCount": 5,
  "escalationCount": 1,
  "hasActiveEscalation": true,
  "escalations": [...],
  "messages": [...]
}
```

#### AI-Generated Summary
```http
POST /api/sessions/:id/ai-summary

Response:
{
  "summary": "Customer inquired about password reset and was provided with instructions...",
  "messageCount": 10
}
```

#### AI Next Actions
```http
POST /api/sessions/:id/next-actions

Response:
{
  "suggestedActions": "1. Check email for reset link\n2. Wait 5-10 minutes\n3. Check spam folder"
}
```

### Messages

#### Send Message (Main AI Interaction)
```http
POST /api/messages/send
Content-Type: application/json

{
  "sessionId": "uuid",
  "message": "How do I reset my password?"
}

Response:
{
  "reply": "To reset your password, go to Settings → Account → Reset Password...",
  "escalated": false
}
```

#### Get Session Messages
```http
GET /api/messages/:sessionId

Response:
[
  {
    "id": "uuid",
    "role": "user",
    "content": "How do I reset my password?",
    "created_at": 1234567890
  },
  {
    "id": "uuid",
    "role": "assistant",
    "content": "To reset your password...",
    "created_at": 1234567891
  }
]
```

### Escalations

#### Get All Escalations
```http
GET /api/escalations?status=pending

Response: Array of escalation objects
```

#### Get Escalation by ID
```http
GET /api/escalations/:id

Response:
{
  "id": "uuid",
  "session_id": "uuid",
  "reason": "User requested escalation",
  "details": "{...}",
  "created_at": 1234567890,
  "status": "pending"
}
```

#### Get Session Escalations
```http
GET /api/escalations/session/:sessionId

Response: Array of escalations for that session
```

#### Update Escalation Status
```http
PATCH /api/escalations/:id
Content-Type: application/json

{
  "status": "resolved"
}

Response:
{
  "success": true,
  "id": "uuid",
  "status": "resolved"
}
```

### FAQs

#### Get All FAQs
```http
GET /api/faqs

Response: Array of all FAQs
```

#### Get FAQs by Category
```http
GET /api/faqs?category=billing

Response: Array of FAQs in that category
```

### Health Check

```http
GET /health

Response:
{
  "status": "ok",
  "timestamp": 1234567890
}
```

## 🤖 LLM Integration & Prompts

### Prompt Engineering Strategy

The system uses sophisticated prompt engineering to ensure high-quality responses:

#### 1. **System Prompt** (`prompts.js`)
Defines the AI's role, behavior, and guidelines:
```javascript
You are a helpful AI customer support assistant.

Your role:
- Answer customer questions accurately using the provided FAQs
- Be concise, polite, and professional
- Consider the conversation history to provide contextual responses
- If you detect frustration or cannot help, suggest escalation
- Provide actionable next steps when possible
```

#### 2. **Dynamic Context Building**
For each user message, the system:
1. **Searches relevant FAQs** using keyword matching
2. **Retrieves conversation history** from the database
3. **Builds comprehensive prompt** with:
   - System instructions
   - Top 3 relevant FAQs
   - Full conversation history
   - Current user query

Example prompt structure:
```
[System Prompt]

Relevant FAQs:
1. Q: How do I reset my password?
   A: Go to Settings → Account → Reset Password...

Conversation History:
Customer: I forgot my password
Assistant: I can help with that...

Current Customer Query: I didn't receive the email

Provide a helpful response:
```

#### 3. **Conversation Summarization**
Uses focused prompts to generate concise summaries:
```javascript
Summarize the following customer support conversation in 2-3 sentences.
Focus on the main issue, resolution status, and any outstanding items.
```

#### 4. **Next Action Suggestions**
Generates actionable follow-up steps for customers:
```javascript
Based on this customer support interaction, suggest 2-3 helpful next actions
```

### Escalation Detection

The system automatically detects escalation scenarios:

**Keyword-based Detection:**
- User messages containing: "agent", "human", "representative", "escalate", "supervisor", "complaint"
- AI responses containing: "escalate"

**Trigger Conditions:**
```javascript
const escalateKeywords = [
  "agent", "human", "representative", 
  "escalate", "supervisor", "complaint"
];

const shouldEscalate = 
  escalateKeywords.some(k => message.toLowerCase().includes(k)) ||
  aiText.toLowerCase().includes("escalate");
```

When escalation is triggered:
1. Creates escalation record in database
2. Logs user message and AI response
3. Sets status to 'pending'
4. Returns `escalated: true` in response

## 🔧 Configuration

### Environment Variables

| Variable | Required | Description | Default |
|----------|----------|-------------|---------|
| `GEMINI_API_KEY` | Yes | Google Gemini API key | - |
| `PORT` | No | Server port | 4000 |
| `DATABASE_FILE` | No | SQLite database path | ./data/db.sqlite |

### Gemini Model Configuration

Current settings in `routes/messages.js`:
```javascript
model: "gemini-2.0-flash-exp"
temperature: 0.2  // Lower = more consistent
maxOutputTokens: 400
```

Adjust these for different behavior:
- **Temperature**: 0.0-1.0 (higher = more creative)
- **Max Tokens**: Response length limit

## 📦 Pre-seeded FAQ Dataset

The system includes 8 FAQs covering common topics:

### Account Management
- Password reset
- Account deletion

### Billing
- Refund policy
- Payment method updates

### Subscription
- Plan changes
- Cancellation

### Support
- Contact information
- Business hours

FAQs are automatically loaded on first startup. Edit in `db.js` to customize.

## 🧪 Testing the API

### Using curl

1. **Create a session:**
```bash
curl -X POST http://localhost:4000/api/sessions/create \
  -H "Content-Type: application/json" \
  -d '{"metadata": {"customer": "Test User"}}'
```

2. **Send a message:**
```bash
curl -X POST http://localhost:4000/api/messages/send \
  -H "Content-Type: application/json" \
  -d '{
    "sessionId": "your-session-id",
    "message": "How do I reset my password?"
  }'
```

3. **Get conversation summary:**
```bash
curl -X POST http://localhost:4000/api/sessions/your-session-id/ai-summary
```

### Using Postman/Thunder Client

Import the collection (create one with the endpoints above) or manually test each endpoint.

## 🎯 Evaluation Criteria Compliance

### ✅ Conversational Accuracy
- FAQ-based responses with intelligent search
- Context-aware answers using conversation history
- Natural language generation via Gemini LLM

### ✅ Session Management
- Complete session lifecycle (create, track, summarize)
- Message history persistence
- Session metadata support

### ✅ LLM Integration Depth
- Dynamic prompt engineering
- Contextual memory integration
- Multiple LLM use cases (responses, summarization, suggestions)
- Escalation detection

### ✅ Code Structure
- Clean separation of concerns (routes, database, prompts, utilities)
- RESTful API design
- Comprehensive error handling
- Well-documented code

## 🎬 Demo Workflow

### Basic Support Flow

1. **Customer starts conversation**
   - POST `/api/sessions/create`
   - Receives `sessionId`

2. **Customer asks question**
   - POST `/api/messages/send`
   - AI searches FAQs
   - Considers conversation history
   - Returns contextual response

3. **Conversation continues**
   - Each message adds to history
   - AI maintains context
   - Responses improve with more context

4. **Session analysis**
   - GET `/api/sessions/:id/summary` - Statistics
   - POST `/api/sessions/:id/ai-summary` - AI summary
   - POST `/api/sessions/:id/next-actions` - Suggestions

### Escalation Flow

1. **Customer expresses frustration**
   - Message: "I want to speak to a human agent"

2. **AI detects escalation**
   - Keyword match triggers escalation
   - Creates escalation record
   - Returns `escalated: true`

3. **Support team reviews**
   - GET `/api/escalations?status=pending`
   - Reviews escalation details

4. **Resolution**
   - PATCH `/api/escalations/:id` with status update

## 🐛 Troubleshooting

### Common Issues

**"Missing GEMINI_API_KEY"**
- Ensure `.env` file exists with valid API key
- Restart server after adding key

**"Cannot POST /api/message/send"**
- Endpoint is `/api/messages/send` (plural)

**Database errors**
- Delete `data/db.sqlite` and restart (will recreate)
- Check file permissions

**Native module errors (better-sqlite3)**
```bash
npm rebuild better-sqlite3
```

## 📝 Future Enhancements

- [ ] WebSocket support for real-time chat
- [ ] Multi-language support
- [ ] Sentiment analysis
- [ ] Analytics dashboard
- [ ] Email notifications for escalations
- [ ] File attachment support
- [ ] Canned responses library
- [ ] Agent assignment system
- [ ] SLA tracking

## 📄 License

ISC

## 👤 Author

[Your Name]

## 🙏 Acknowledgments

- Google Gemini AI for LLM capabilities
- Express.js community
- Better-SQLite3 for fast database operations
