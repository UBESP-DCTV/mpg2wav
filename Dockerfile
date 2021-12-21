FROM node:latest

WORKDIR /usr/src/app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY dev/speechFileToText/. .

RUN npm install


EXPOSE 8080
CMD ['npm', 'start']
