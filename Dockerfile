FROM python:3.6

ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

ENV SECRET_KEY i)1pu*ftk99hkx(9u78lmi@3b7pg-yt)!%dvki=z1sz&%s!hk9
ENV DJANGO_ALLOWED_HOSTS inventory-management-web.ap-south-1.elasticbeanstalk.com localhost 127.0.0.1 [::1]

ENV APP_HOME=/home/app

RUN mkdir -p ${APP_HOME}

WORKDIR $APP_HOME

RUN python -m pip install --upgrade pip

COPY ./requirements.txt $APP_HOME

RUN pip install -r requirements.txt

COPY . $APP_HOME

EXPOSE 8000

ENTRYPOINT ["/home/app/entrypoint.sh"]