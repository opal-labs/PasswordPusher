FROM docker.io/ubuntu:18.04

# Use the following 2 env variables if you need proxy support in your environment
#ENV https_proxy=http://10.0.2.2:3128
#ENV http_proxy=http://10.0.2.2:3128

RUN ln -fs /usr/share/zoneinfo/America/Toronto > /etc/localtime
RUN apt-get update -qq
RUN apt-get install -y --assume-yes build-essential libpq-dev git curl ruby2.5 ruby2.5-dev tzdata sqlite3 ruby-sqlite3 libsqlite3-dev zlib1g-dev dos2unix

ENV APP_ROOT=/opt/PasswordPusher
ENV PATH=${APP_ROOT}:${PATH} HOME=${APP_ROOT}
ENV DATABASE_URL=postgres://postgres:ErYukwav5VT5BgeKqP9XY9AS2dqkBTkdhhkxHMVPQC9EkNT8kzZ3wPUuh7fAwhte@68.183.202.193:5432/password-pusher?sslmode=disable

RUN mkdir ${APP_ROOT}
COPY . ${APP_ROOT}
RUN touch ${APP_ROOT}/log/production.log && \
    cd ${APP_ROOT} && \
    gem install bundler:1.17.3 && \
    gem install thor && \
    chown -R 1001:root ${APP_ROOT}

EXPOSE 5000

USER 1001
WORKDIR ${APP_ROOT}
RUN bundle install --without development private test --deployment && \
    bundle exec rake assets:precompile && \
    RAILS_ENV=production

USER root
RUN chmod -R u+x ${APP_ROOT} && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} /etc/passwd
RUN find ${APP_ROOT} -type f -print0 | xargs -0 dos2unix

USER 1001
WORKDIR ${APP_ROOT}
ENTRYPOINT ["containerization/pwpush-postgres/entrypoint.sh"]