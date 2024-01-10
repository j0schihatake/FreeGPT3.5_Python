from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import g4f
import asyncio

app = FastAPI()

# Убираем использование uvloop
asyncio.set_event_loop_policy(asyncio.DefaultEventLoopPolicy())

g4f.debug.logging = True  # Включаем логирование
g4f.debug.version_check = False  # Отключаем автоматическую проверку версии
print(g4f.Provider.Bing.params)  # Выводим поддерживаемые аргументы для Bing


class Message(BaseModel):
    message: str


@app.post("/chat")
async def chat_completion(message: Message):
    try:
        response = g4f.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "system", "content": "You are a helpful assistant."},
                      {"role": "user", "content": message.message}],
            stream=True
        )
        result = ""
        for message in response:
            result += message['content']
        return {"response": result}
    except Exception as e:
        print(f"Error processing chat_completion: {e}")
        raise HTTPException(status_code=500, detail="Internal Server Error")


@app.post("/chat/alternative")
async def alternative_chat_completion(message: Message):
    try:
        response = g4f.ChatCompletion.create(
            model=g4f.models.gpt_4,
            messages=[{"role": "system", "content": "You are a helpful assistant."},
                      {"role": "user", "content": message.message}]
        )
        return {"response": response[0]['content']}
    except Exception as e:
        print(f"Error processing alternative_chat_completion: {e}")
        raise HTTPException(status_code=500, detail="Internal Server Error")
