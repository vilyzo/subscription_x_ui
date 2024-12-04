FROM python:3.9-slim
# RUN groupadd -r docker-group && useradd -r -g docker-group docker-user
WORKDIR /app
COPY requirements.txt .
RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt
COPY . /app
# USER docker-user
EXPOSE 8000

CMD ["uvicorn", "app:app", "--host", "127.0.0.1", "--port", "8000"]
