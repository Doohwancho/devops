# case1) npm으로 프론트 서버 실행
FROM node:14.17.6-alpine

RUN mkdir /app
WORKDIR /app

ENV PATH /app/node_modules/.bin:$PATH
COPY package.json package.json
RUN npm install --silent
RUN npm install react-scripts@3.0.1 -g --silent 
#react-scripts 3.0.1버전은 https 요청없이 http 요청 만 할 때 사용
COPY . .
CMD ["npm", "run", "start"]

