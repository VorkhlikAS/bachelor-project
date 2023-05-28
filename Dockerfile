FROM python:3

WORKDIR /app

COPY requirements.txt /app

# RUN pip install --no-cache-dir --upgrade pip \
#   && pip install --no-cache-dir -r requirements.txt

RUN pip install -r requirements.txt

COPY . /app

EXPOSE 5000

CMD ["python", "route.py"]
