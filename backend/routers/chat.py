from fastapi import APIRouter
from typing import List, Dict, Optional
from pydantic import BaseModel
from backend.database.models import ChatMessage, CaseInterview 
from backend.database.db import cases 
from backend.services.llm_service import get_ai_response_initial, get_ai_response_follow_up, gen_ai_response_question, gen_ai_response_answer, gen_ai_response_analysis
import yaml
from backend.database.models import InitialChatRequest, AIResponseMessage, FollowUpChatRequest

with open("backend/prompts.yaml", 'r') as f:
    prompts = yaml.safe_load(f)
initial_instructions = prompts.get(
    'initial_interaction_prompt',
    prompts.get('default_system_prompt')
)

router = APIRouter()



# In backend/routers/chat.py

# You'll need to load prompts from your prompts.yaml
# For example:


@router.post("/initiate_chat", response_model=AIResponseMessage)
async def initiate_chat_session(request_data: InitialChatRequest):
    case_id = request_data.case_id
    current_case = next((case for case in cases if case.id == case_id), None)
    if not current_case:
        raise HTTPException(status_code=404, detail="Case not found")
    
    # Construct a meaningful context for the initial call
    case_context_for_llm = f"Client: {current_case.description.client_name}. Goal: {current_case.description.client_goal}. Situation: {current_case.description.situation_description}"
    
    # Define or load initial instructions (system prompt for the very first message)
    # This might be a generic greeting and case introduction prompt
    initial_instructions = "You are an AI case interviewer. Start by introducing the case to the user and provide any initial instructions or context. The case is about: " + current_case.name

    # Assuming get_ai_response_initial returns a dict like {"response_id": "...", "ai_message": "..."}
    # or just the message string as per your llm_service.py (line 55 returns string)
    # Let's adjust based on llm_service.py returning a string for the initial message
    # and assuming it doesn't return a response_id for the *very first* interaction in this specific function.
    # Your llm_service.py get_ai_response_initial returns a string.
    # The client.responses.create might be from a specific OpenAI library version or helper.
    # For now, I'll assume it returns the message string.
    # If it's meant to return a dict with response_id, adjust accordingly.

    ai_message_content = await get_ai_response_initial(
        instructions=initial_instructions, # You'll need to define these
        current_case_context=case_context_for_llm
    )
    # If get_ai_response_initial is supposed to give a response_id for follow-up,
    # you'll need to capture that. For now, assuming it's just the first message.
    # The concept of response_id seems more for client.responses.create in your llm_service
    
    # For the very first message, a response_id to chain might not be applicable
    # from get_ai_response_initial if it's just a simple completion.
    # Your follow-up functions *do* use response_id.
    # This suggests the initial call might need to use a different mechanism or
    # the `client.responses.create` in `get_ai_response_initial` should also yield an ID.
    # Let's assume for now the first message doesn't need to provide a response_id back to client,
    # but the client will need to store this first AI message to build history.
    # OR, the first call should use a method that gives a response_id.

    # To align with your `get_ai_response_follow_up` which expects a response_id,
    # the initial interaction should ideally also establish one.
    # This might mean `get_ai_response_initial` needs to be adapted or you use
    # a different OpenAI client method that provides a session/thread ID from the start.

    # For simplicity in this plan, let's assume the first message is fetched,
    # and subsequent messages will use a follow-up endpoint.
    # The "response_id" for the *next* call will be tricky if not returned by initial.
    # This is a critical point in your llm_service.py design with `client.responses.create`.

    return AIResponseMessage(ai_message=ai_message_content) # No response_id from initial for now
