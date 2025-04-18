FROM python:3.12.9-bullseye

RUN mkdir /bike_sharing_api
RUN mkdir /bike_sharing_api/app
RUN mkdir /bike_sharing_api/app/schemas
WORKDIR /bike_sharing_api
COPY dist/*.whl /bike_sharing_api
COPY bike_sharing_api/app/*.py /bike_sharing_api/app/
COPY bike_sharing_api/app/schemas/*.py /bike_sharing_api/app/schemas/
COPY bike_sharing_api/requirements.txt /bike_sharing_api/
RUN pip install -r /bike_sharing_api/requirements.txt

CMD ["python","app/main.py"]

