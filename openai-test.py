from openai import OpenAI, APIError

client = OpenAI(api_key="sk-")

response = client.responses.create(
    model="gpt-4.1-mini",
    input="Hello, how are you?",
    instructions="You are a helpful assistant that can answer questions and help with tasks.",
    temperature=0.5,
)

print(response)
response_id = response.id
ai_message = response.output[0].content[0].text.strip()
ai_message2 = response.output_text.strip()
print(f"Response ID: {response_id}")
print(f"AI Message: {ai_message}")
print(f"AI Message 2: {ai_message2}")

