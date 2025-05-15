from fastapi import FastAPI
from pydantic import BaseModel
from typing import List
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="McKinsey Case Interviews API")

# Allow all origins during development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class CaseInterview(BaseModel):
    name: str
    source: str
    url: str 
    description: str

# Predefined list of McKinsey case interviews with updated descriptions
cases: List[CaseInterview] = [
    CaseInterview(
        name="Beautify case interview",
        source="McKinsey website",
        url="https://www.mckinsey.com",
        description=
            "Our client is Beautify. Beautify has approached McKinsey for help with exploring new ways to approach its customers."
        ,
    ),
    CaseInterview(
        name="Bill & Melinda Gates Foundation case interview",
        source="McKinsey website",
        url="https://www.mckinsey.com",
        description=
            "The Bill & Melinda Gates Foundation is a private organization with vast ambitions; one of its goals is to reduce extreme poverty worldwide. "
            "The foundation has asked McKinsey to design a basic financial-services offering for residents in remote communities in Mexico."
        ,
    ),
    CaseInterview(
        name="SuperSoda case interview",
        source="McKinsey website",
        url="https://www.mckinsey.com",
        description=
            "Our client is SuperSoda, a top-three beverage producer in the United States that has approached McKinsey for help designing its product launch strategy."
        ,
    ),
    CaseInterview(
        name="GlobaPharm case interview",
        source="McKinsey website",
        url="https://www.mckinsey.com",
        description=
            "Our client is GlobaPharm, a major pharmaceutical company (pharmaco) with $10 billion a year in revenue. Its corporate headquarters and primary research "
            "and development (R&D) centers are in Germany, with regional sales offices worldwide."
        ,
    ),
    CaseInterview(
        name="Loravia Education case interview",
        source="McKinsey website",
        url="https://www.mckinsey.com",
        description=
            "Loravia is a fictional country located in Eastern Europe with a population of 20 million. The government of Loravia wants to make major improvements in both "
            "the quantity and quality of education for its children. Because McKinsey has a great deal of global knowledge and expertise in the education sector, the Loravian "
            "department of education has asked McKinsey to advise on how it can achieve this transformation of its school system."
        ,
    ),
    CaseInterview(
        name="Talbot Trucks case interview",
        source="McKinsey website",
        url="https://www.mckinsey.com",
        description=
            "Our client is Talbot Trucks. Talbot Trucks has approached McKinsey for help in assessing the feasibility of manufacturing electric trucks to reduce its fleet’s carbon footprint."
        ,
    ),
    CaseInterview(
        name="Shops Corporation case interview",
        source="McKinsey website",
        url="https://www.mckinsey.com",
        description=
            "Our client is Shops Corporation. Shops Corporation approached McKinsey for help to improve diversity, equity and inclusion within their company."
        ,
    ),
    CaseInterview(
        name="Conservation Forever case interview",
        source="McKinsey website",
        url="https://www.mckinsey.com/careers/interviewing/conservation-forever",
        description=
            "Our client is Conservation Forever (CF), a conservation-focused nongovernmental organization (NGO). CF has asked McKinsey to help prioritize restoration and conservation efforts."
        ,
    ),
]

@app.get("/cases", response_model=List[CaseInterview])
async def get_cases():
    """
    Returns a list of McKinsey case interviews with detailed descriptions.
    """
    return cases
