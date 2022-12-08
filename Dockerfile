# here we are creating an image for our python app
# python:alpine is our base image
FROM python:alpine
COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt
# we are using EXPOSE for meta data
EXPOSE 80 
CMD python ./bookstore-api.py

