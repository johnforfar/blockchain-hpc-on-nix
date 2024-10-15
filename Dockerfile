FROM node:22-alpine
COPY . /usr/src/app
WORKDIR /usr/src/app
RUN apk add git bash openssh ;
RUN yarn install --non-interactive --frozen-lockfile
