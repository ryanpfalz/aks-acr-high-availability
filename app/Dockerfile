# syntax=docker/dockerfile:1
FROM python:3.8

COPY . .
WORKDIR /api
RUN pip install --no-cache-dir -r requirements-prod.txt

EXPOSE 8080
ENTRYPOINT ["python"]
CMD ["app.py"]