

FROM node:latest

COPY . .

RUN npm install
RUN npx docusaurus build

ENTRYPOINT ["npx", "docusaurus", "serve", "--port", "8080", "--host", "0.0.0.0"]