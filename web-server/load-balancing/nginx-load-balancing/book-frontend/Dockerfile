FROM node:14.17.6-alpine

RUN mkdir /app
WORKDIR /app

ENV PATH /app/node_modules/.bin:$PATH
COPY package.json /app/package.json
RUN npm install
COPY . .
CMD ["npm", "run", "start"]