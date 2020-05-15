FROM node:latest

COPY server server
COPY package.json .
COPY package-lock.json .

RUN npm install

EXPOSE 4000

CMD npm run server