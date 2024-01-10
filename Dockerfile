# Dockerfile to deploy a llama-cpp container with conda-ready environments

#RUN docker pull continuumio/miniconda3:latest

ARG TAG=latest
FROM continuumio/miniconda3:$TAG

RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        git \
        uvicorn \
        libportaudio2 \
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
        openssh-server \
        libglib2.0-0 \
        libsm6 \
        libgl1 \
        libxrender1 \
        libxext6 \
        ffmpeg \
        wget \
        curl \
        psmisc \
        rsync \
        vim \
        unzip \
        htop \
        pkg-config \
        libcairo2-dev \
        libgoogle-perftools4 libtcmalloc-minimal4  \
    && rm -rf /var/lib/apt/lists/*

# Setting up locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

# Create user
RUN groupadd --gid 1020 free-gpt-group
RUN useradd -rm -d /home/free-gpt-user -s /bin/bash -G users,sudo,free-gpt-group -u 1000 free-gpt-user

# Update user password
RUN echo 'free-gpt-user:admin' | chpasswd

RUN python3 -m pip install pydantic uvicorn[standard] fastapi

# Download latest github/llama-cpp in llama.cpp directory and compile it
RUN git clone https://github.com/xtekky/gpt4free.git ~/gpt4free && \
    cd ~/gpt4free && \
    git pull

# Install Requirements for llama.cpp
RUN cd ~/gpt4free && \
    python3 -m pip install -r requirements.txt

RUN python3 -m pip install -U g4f

RUN mkdir /home/free-gpt-user/freegpt

RUN mkdir /home/free-gpt-user/freegpt/src

ADD src/freegpt.py /home/free-gpt-user/freegpt/src

RUN chmod 777 /home/free-gpt-user/freegpt
ENV HOME /home/free-gpt-user/freegpt/
WORKDIR ${HOME}
USER free-gpt-user

# Запуск Fast api:
CMD uvicorn src.freegpt:app --host 0.0.0.0 --port 8090 --reload

# запуск:
# docker build -t gptfree .
# docker run -dit --name gptfree -p 8090:8090 --gpus all --restart unless-stopped gptfree:latest