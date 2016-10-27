FROM elixir:1.3

MAINTAINER Bruno Abrantes <bruno@brunoabrantes.com>

ENV PORT 8888
ENV MIX_ENV prod
ENV HOST localhost
ENV DEBIAN_FRONTEND noninteractive

EXPOSE 8888

ADD . /app

WORKDIR /app

RUN rm -rf deps node_modules

RUN apt-get update
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install -y nodejs

RUN mix local.hex --force
RUN mix local.rebar --force_ssl

RUN mix deps.get
RUN npm install
RUN npm run deploy
RUN mix compile
RUN mix phoenix.digest

CMD ["mix", "phoenix.server"]
