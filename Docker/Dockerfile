FROM python:3.11-slim

WORKDIR /app

COPY app/hello_server.py .

ARG CI_ID

ENV CI_ID=${CI_ID}

EXPOSE 80

CMD ["python", "hello_server.py"]