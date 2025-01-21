FROM ruby:3.1.1
ENV BUNDLER_VERSION=2.4.6

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update
RUN apt-get install -yqq \
  default-libmysqlclient-dev \
  libcurl4-openssl-dev \
  build-essential \
  nodejs \
  yarn \
  bash \
  default-mysql-client \
  libcurl3-dev \
  openssh-client \
  nano

RUN useradd -m user
RUN mkdir -p /home/user/.ssh
RUN chown -R user:user /home/user/.ssh
USER user
CMD ["/bin/bash"]

RUN gem install bundler -v 2.4.6


WORKDIR /app

COPY Gemfile ./

RUN bundle config build.nokogiri --use-system-libraries

COPY . ./

COPY --chown=user:user Gemfile.lock ./

RUN chmod 777 ./Gemfile.lock

#RUN ["chmod", "+x", "./entrypoints/docker-entrypoint.sh"]
#RUN ["chmod", "+x", "./entrypoints/sidekiq-entrypoint.sh"]
# ENTRYPOINT ["./entrypoints/docker-entrypoint.sh"]

