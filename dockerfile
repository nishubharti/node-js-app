FROM registry.access.redhat.com/ubi8/nodejs-16@sha256:7a13834164db1458d8d97df2eca9f117cc4472b60c9ce7761c1146fd9a7effcd
USER root
RUN yum update -y && yum upgrade -y
RUN npm -v
ENV PORT 8080
WORKDIR /usr/src/app
RUN chown -R 1001:0 /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .
USER 1001
EXPOSE 8080
CMD [ "npm", "start" ]
