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
    # Print all available providers
    print([
        provider.__name__
        for provider in g4f.Provider.__providers__
        if provider.working
    ])

    # Execute with a specific provider
    response = g4f.ChatCompletion.create(
        model="gpt-3.5-turbo",
        provider=g4f.Provider.Aichat,
        cookies={"a": "b"},
        messages=[{"role": "user", "content": message.message}],
        stream=True,
    )
    for message in response:
        print(message)
    return {"response": message}
