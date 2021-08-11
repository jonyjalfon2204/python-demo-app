# syntax=docker/dockerfile:1
FROM python:3.7-slim AS base
WORKDIR /app
RUN pip install pipenv==2021.5.29

COPY Pipfile /app/
#COPY Pipfile.lock /app/

RUN pipenv install --deploy


FROM base AS app
COPY src /app


FROM base AS test-base
RUN pipenv install --deploy --dev
RUN pip install flask pytest-flask pytest pycco safety pytest-black
COPY src /app


FROM test-base AS Test
RUN pytest --black


FROM test-base AS Check
RUN safety check

FROM app AS release
EXPOSE 5000
CMD ["python", "app.py"]


FROM release AS Dev
ENV FLASK_ENV=development


FROM release As Prod
CMD ["gunicorn", "-b", ":5000", "app:app"]
