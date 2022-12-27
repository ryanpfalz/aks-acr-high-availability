FROM python:3-slim

COPY . .
WORKDIR /api
RUN pip install --no-cache-dir -r requirements-prod.txt

EXPOSE 8080
ENTRYPOINT ["python"]
CMD ["app.py"]