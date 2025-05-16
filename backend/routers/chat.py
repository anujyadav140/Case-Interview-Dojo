from fastapi import APIRouter
from typing import List, Dict
from backend.database.models import ChatMessage, CaseInterview 
from backend.database.db import cases 
from backend.services.llm_service import get_ai_response, generate_session_summary

router = APIRouter()

DEFAULT_SYSTEM_PROMPT = (
    "You are an expert case interviewer. Your goal is to guide the user through a case study. "
    "Present questions from the case one by one. Be encouraging and help the user think through "
    "their responses. Ask clarifying questions if needed. Do not reveal answers directly unless "
    "specifically instructed or if the user is completely stuck after multiple attempts. "
    "Maintain a professional and supportive tone."
)

class ChatInteractionRequest(ChatMessage):
    """Model for the user's message in a chat interaction."""
    pass

class ChatInteractionResponse(ChatMessage):
    """Model for the AI's response in a chat interaction."""
    pass

class SessionSummaryResponse(BaseModel):
    summary: str

