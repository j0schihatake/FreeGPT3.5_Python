# Dockerfile to deploy a llama-cpp container with conda-ready environments

#RUN docker pull continuumio/miniconda3:latest

ARG TAG=latest
FROM continuumio/miniconda3:$TAG

RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        git \
        uvicorn \
        locales \
        sudo \
        build-essential \
        dpkg-dev \
        ca-certificates \
        netbase\
        tzdata \
        nano \
        software-properties-common \
        python3-venv \
        python3-tk \
        pip \
        bash \
        ncdu \
        net-tools \
        wget \
        curl \
        psmisc \
        rsync \
        vim \
        unzip \
        htop \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Setting up locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

# Create user
RUN groupadd --gid 1020 free-gpt-group
RUN useradd -rm -d /home/free-gpt-user -s /bin/bash -G users,sudo,free-gpt-group -u 1000 free-gpt-user

# Update user password
RUN echo 'free-gpt-user:admin' | chpasswd

# Download latest github/llama-cpp in llama.cpp directory and compile it
RUN git clone https://github.com/xtekky/gpt4free.git ~/gpt4free && \
    cd ~/gpt4free && \
    git pull

# Install Requirements for llama.cpp
RUN cd ~/gpt4free && \
    python3 -m pip install -r requirements.txt

# Устанавливаем начальную директорию
ENV HOME /home/llama-cpp-user/server
WORKDIR ${HOME}

# Запуск Fast api:
CMD uvicorn src.main:app --host 0.0.0.0 --port 8082 --reload

# запуск:
# в main.py указать имя модели которую собираемся использовать
# docker build -t llamaserver .
# docker run -dit --name llamaserver -p 8082:8082 -v D:/Develop/NeuronNetwork/llama_cpp/llama_cpp_java/model/:/home/llama-cpp-user/model/  --gpus all --restart unless-stopped llamaserver:latest
# или:
# docker run -dit --name llamaserver -p 8082:8082 -v C:/Program/Models/:/home/llama-cpp-user/model/  --gpus all --restart unless-stopped llamaserver:latest

# Запуск на cpu:
# docker run -dit --name llamaserver -p 8082:8082 -v C:/Program/Models/:/home/llama-cpp-user/model/ --restart unless-stopped llamaserver:latest

# Debug
# docker container attach llamaserver
