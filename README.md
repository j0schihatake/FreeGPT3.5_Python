# FreeGPT3.5_Python
Альтернативный запуск в docker.


Проект не сработал, github: https://github.com/ChatTeach/FreeGPT

Проект так-же не сработал: https://github.com/fantasy-peak/cpp-freegpt-webui

Рабочий проект:
https://github.com/xtekky/gpt4free

Команды:

docker pull hlohaus789/g4f 

docker run -p 8080:8080 -p 1337:1337 -p 7900:7900 --shm-size="2g" hlohaus789/g4f:latest
