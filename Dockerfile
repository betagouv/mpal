FROM ruby:2.3.1

RUN apt-get update && apt-get install -y nodejs build-essential qt5-default libqt5webkit5-dev

RUN mkdir -p /app
WORKDIR /app

ADD Gemfile /app/Gemfile  
ADD Gemfile.lock /app/Gemfile.lock  
ENV NOKOGIRI_USE_SYSTEM_LIBRARIES=1
RUN bundle install

RUN gem install foreman
RUN gem install rb-readline

ADD . /app

CMD foreman start
