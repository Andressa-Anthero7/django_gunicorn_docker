# Baseada na imagem leve do Python
FROM python:3.10-slim

# Diretório de trabalho dentro do contêiner
WORKDIR /app

# Instalar dependências do sistema necessárias e criar venv
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    libjpeg-dev \
    zlib1g-dev && \
    python3 -m venv /app/venv && \
    /app/venv/bin/pip install --upgrade pip && \
    rm -rf /var/lib/apt/lists/*

# Adicionar o venv ao PATH
ENV PATH="/app/venv/bin:$PATH"

# Copiar e instalar dependências do Python
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Criar um usuário não-root para rodar a aplicação
RUN useradd -m django
USER django

# Copiar o código do projeto para o contêiner
COPY . /app/

# Expor a porta onde o Gunicorn rodará
EXPOSE 8000

# Comando padrão (configurável via ENV)
ENV GUNICORN_CMD="gunicorn base.wsgi:application --bind 0.0.0.0:8000 --workers 3"
CMD $GUNICORN_CMD
