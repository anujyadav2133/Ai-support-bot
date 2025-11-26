# Prompt Engineering Documentation

This document explains the prompt engineering strategies used in the AI Customer Support Bot.

## 🎯 Prompt Design Philosophy

Our prompts are designed with these principles:
1. **Clarity**: Clear role definition and expectations
2. **Context**: Relevant FAQs and conversation history
3. **Consistency**: Structured format for reliable responses
4. **Helpfulness**: Focus on actionable, customer-friendly responses

## 📋 Main Prompts

### 1. System Prompt (Customer Support)

**Location**: `backend/prompts.js` - `systemPrompt`

**Purpose**: Defines the AI assistant's role, behavior, and guidelines

```javascript
You are a helpful AI customer support assistant. 

Your role:
- Answer customer questions accurately using the provided FAQs
- Be concise, polite, and professional
- Consider the conversation history to provide contextual responses
- If you detect frustration or cannot help, suggest escalation to a human agent
- Provide actionable next steps when possible

Guidelines:
- Use FAQ answers when available, but phrase them naturally
- Ask clarifying questions only when crucial
- If the user asks about refunds, billing issues, or complex problems, consider escalation
- If the user explicitly requests a human agent, acknowledge and escalate
- Keep responses under 3-4 sentences unless more detail is needed
```

**Design Rationale**:
- **Clear boundaries**: Defines what the AI should and shouldn't do
- **Escalation guidance**: Explicit instructions on when to escalate
- **Tone setting**: Professional, concise, helpful
- **Length control**: Prevents overly verbose responses

### 2. Dynamic Message Prompt

**Location**: `backend/prompts.js` - `buildPromptFromSession()`

**Purpose**: Constructs the full prompt for each user message with context

**Structure**:
```
[System Prompt]

Relevant FAQs:
1. Q: [Question]
   A: [Answer]
2. Q: [Question]
   A: [Answer]
...

Conversation History:
Customer: [Previous message]
Assistant: [Previous response]
...

Current Customer Query: [User's latest message]

Provide a helpful response:
```

**Dynamic Components**:

1. **FAQ Selection** (Top 3 relevant):
   ```javascript
   const relevantFAQs = searchFAQs(userMessage, 3);
   ```
   - Searches FAQs by keywords
   - Scores by relevance
   - Includes only top matches to save tokens

2. **Conversation History**:
   ```javascript
   sessionMessages.forEach(msg => {
     const speaker = msg.role === 'user' ? 'Customer' : 'Assistant';
     conversationContext += `${speaker}: ${msg.content}\n`;
   });
   ```
   - Full message history for context
   - Labeled as "Customer" and "Assistant"
   - Chronological order

3. **Current Query**:
   - Clearly marked as the question to answer
   - Separated from history for clarity

**Example Generated Prompt**:
```
You are a helpful AI customer support assistant...

Relevant FAQs:
1. Q: How do I reset my password?
   A: Go to Settings → Account → Reset Password. You will receive an email with a reset link.

Conversation History:
Customer: I forgot my password
Assistant: I can help you reset your password. Go to Settings → Account → Reset Password...
Customer: I didn't get the email

Current Customer Query: It's been 10 minutes

Provide a helpful response:
```

### 3. Summarization Prompt

**Location**: `backend/prompts.js` - `buildSummarizationPrompt()`

**Purpose**: Generate concise summaries of support conversations

**Template**:
```javascript
Summarize the following customer support conversation in 2-3 sentences. 
Focus on the main issue, resolution status, and any outstanding items.

Conversation:
[Full conversation with Customer/Assistant labels]

Summary:
```

**Design Choices**:
- **Length constraint**: "2-3 sentences" keeps it brief
- **Focus areas**: Issue, resolution, outstanding items
- **Format**: Simple, structured conversation input

**Example Output**:
```
Customer inquired about password reset and didn't receive the reset email. 
Assistant advised checking spam folder and waiting up to 30 minutes for delivery. 
Issue remains unresolved pending email receipt.
```

### 4. Next Actions Prompt

**Location**: `backend/prompts.js` - `buildNextActionPrompt()`

**Purpose**: Suggest actionable next steps for the customer

**Template**:
```javascript
Based on this customer support interaction, suggest 2-3 helpful next actions 
for the customer.

Customer: [Last user message]
Assistant: [Last AI response]

Suggested next actions (as a simple list):
```

**Design Choices**:
- **Limited context**: Only last exchange (saves tokens)
- **Specific format**: "simple list" for consistency
- **Count limit**: "2-3" prevents overwhelming options

**Example Output**:
```
1. Check your spam/junk folder for the password reset email
2. Wait 20-30 minutes and try the reset process again
3. Contact support@company.example if the issue persists after 1 hour
```

## 🔧 Prompt Engineering Techniques Used

### 1. Role Definition
```
You are a helpful AI customer support assistant.
```
- Clear identity establishes behavior baseline
- "helpful" encourages positive, solution-oriented responses

### 2. Explicit Instructions
```
- Be concise, polite, and professional
- Keep responses under 3-4 sentences unless more detail is needed
```
- Prevents common LLM issues (verbosity, tone problems)
- Measurable guidelines

### 3. Conditional Logic
```
If you detect frustration or cannot help, suggest escalation to a human agent
```
- Teaches decision-making
- Handles edge cases gracefully

### 4. Context Injection
```
Relevant FAQs:
[Top 3 matching FAQs]
```
- Provides factual grounding
- Reduces hallucination
- Improves accuracy

### 5. Few-Shot Learning (Implicit)
```
Conversation History:
Customer: [Previous]
Assistant: [Previous]
```
- Shows AI how it has been responding
- Maintains consistency in multi-turn conversations

### 6. Output Formatting
```
Suggested next actions (as a simple list):
```
- Guides response structure
- Makes parsing easier
- Improves consistency

## 📊 Prompt Optimization Strategies

### Token Efficiency

**Problem**: Long prompts cost more and slow responses

**Solutions**:
1. **Limited FAQ inclusion**: Top 3 instead of all FAQs
   ```javascript
   searchFAQs(userMessage, 3)  // Not searchFAQs(userMessage, 10)
   ```

2. **Concise system prompts**: Clear but brief instructions

3. **Smart history truncation**: Could add (future enhancement):
   ```javascript
   const recentMessages = sessionMessages.slice(-6);  // Last 6 messages only
   ```

### Response Quality

**Problem**: Ensure consistent, high-quality responses

**Solutions**:
1. **Temperature setting**: `0.2` for consistency
   ```javascript
   generationConfig: {
     temperature: 0.2,  // Lower = more deterministic
     maxOutputTokens: 400
   }
   ```

2. **Clear guidelines**: Specific behavioral instructions

3. **Grounding in FAQs**: Factual basis reduces hallucination

### Escalation Detection

**Dual Approach**:

1. **Keyword-based** (Fast, simple):
   ```javascript
   const escalateKeywords = [
     "agent", "human", "representative", 
     "escalate", "supervisor", "complaint"
   ];
   ```

2. **AI-based** (Smart, contextual):
   ```javascript
   aiText.toLowerCase().includes("escalate")
   ```
   - AI can detect when it should escalate
   - More nuanced than keywords alone

## 🎯 Prompt Testing Results

### Metrics Tracked

1. **Response Quality**:
   - Accuracy: Are FAQ answers correct?
   - Relevance: Does response address the question?
   - Tone: Professional and helpful?

2. **Context Retention**:
   - Multi-turn coherence: Does AI remember previous messages?
   - Pronoun resolution: Can it handle "it", "that", etc.?

3. **Escalation Accuracy**:
   - True Positives: Correctly escalates when needed
   - False Positives: Doesn't escalate unnecessarily

### Sample Test Cases

**Test 1: FAQ Accuracy**
```
Input: "How do I reset my password?"
Expected: Accurate FAQ answer about Settings → Account → Reset Password
Result: ✅ Correct
```

**Test 2: Context Retention**
```
Turn 1: "I want to cancel my subscription"
Turn 2: "Can I get a refund?"
Expected: AI understands "I" still refers to subscription context
Result: ✅ Maintains context
```

**Test 3: Escalation Detection**
```
Input: "This is ridiculous! I need a human!"
Expected: Escalation triggered
Result: ✅ Escalated with keywords
```

## 🚀 Advanced Techniques

### 1. Dynamic FAQ Relevance

Instead of static FAQs, we search dynamically:

```javascript
export function searchFAQs(query, limit = 3) {
  // Score each FAQ by:
  // - Exact question match (100 points)
  // - Question contains query (50 points)
  // - Word matching in question (10 points each)
  // - Keyword matching (8 points each)
  // - Word in answer (3 points each)
}
```

This ensures only relevant FAQs are included in prompts.

### 2. Conversation Summarization

Uses a separate LLM call with focused prompt:
- Different temperature (0.3 vs 0.2)
- Shorter max tokens (200 vs 400)
- Specific output format

### 3. Suggested Actions

Generates actionable next steps:
- Based on conversation state
- Formatted as numbered list
- Customer-focused (not internal actions)

## 📝 Best Practices Applied

1. ✅ **Clear role definition**: AI knows it's a support assistant
2. ✅ **Context provision**: FAQs + history for grounding
3. ✅ **Output constraints**: Length, format, tone guidelines
4. ✅ **Error handling**: Escalation paths for failure cases
5. ✅ **Iterative refinement**: Prompts tested and adjusted
6. ✅ **Token optimization**: Only relevant context included
7. ✅ **Consistent structure**: Same format across calls

## 🔄 Iterative Improvements

### Version History

**v1.0**: Basic system prompt
- Simple instruction: "You are a support bot"
- No FAQ integration
- No escalation guidance

**v2.0**: Added FAQ context
- Included all FAQs in prompt
- Added conversation history
- Issue: Too many tokens

**v3.0 (Current)**: Optimized
- Dynamic FAQ search (top 3)
- Enhanced system prompt with guidelines
- Explicit escalation conditions
- Separate prompts for different tasks

### Future Enhancements

1. **Sentiment Analysis Prompt**:
   ```javascript
   Analyze the sentiment of this customer message: [message]
   Output: positive/neutral/negative/frustrated
   ```

2. **Category Classification**:
   ```javascript
   Classify this support query into: account, billing, subscription, technical, other
   Query: [message]
   Category:
   ```

3. **Confidence Scoring**:
   ```javascript
   Rate your confidence in this answer (1-10):
   If below 7, suggest escalation.
   ```

## 📚 References

- **Few-Shot Prompting**: Providing examples in the prompt
- **Chain-of-Thought**: Breaking down reasoning (potential future use)
- **Role-Based Prompting**: Defining AI persona
- **Context Injection**: Providing relevant background information
- **Output Formatting**: Guiding response structure

---

**Maintained by**: Development Team  
**Last Updated**: November 2025  
**Related Files**: `backend/prompts.js`, `backend/routes/messages.js`, `backend/routes/sessions.js`
