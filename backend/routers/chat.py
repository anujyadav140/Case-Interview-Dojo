from fastapi import APIRouter, HTTPException
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
    
    # Format the initial instructions using the case name
    # The global 'initial_instructions' is the template string from prompts.yaml
    formatted_initial_instructions = initial_instructions.replace("{{case_name}}", current_case.name)

    # Call the LLM service to get the initial response
    # get_ai_response_initial is expected to return a Dict {"response_id": ..., "ai_message": ...}
    llm_response = await get_ai_response_initial(
        instructions=formatted_initial_instructions,
        current_case_context=case_context_for_llm
    )

    response_id = llm_response.get("response_id")
    ai_message = llm_response.get("ai_message")

    if ai_message is None:
        # Handle cases where the LLM service might not return an ai_message as expected
        # This could be due to an error in llm_service.py or an unexpected API response
        raise HTTPException(status_code=500, detail="Failed to get AI message from LLM service")

    return AIResponseMessage(response_id=response_id, ai_message=ai_message)
