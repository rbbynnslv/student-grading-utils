FROM node:11-alpine

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk add -U --no-cache --allow-untrusted tzdata chromium ttf-freefont wqy-zenhei ca-certificates && \
    mkdir -p /app /logs && \
    yarn global add pm2 && \
    yarn cache clean && \
    rm -rf /var/cache/apk/*

RUN /bin/sh -c "apk add --no-cache bash"

WORKDIR /student-grading-utils
COPY . /student-grading-utils
COPY package.json /student-grading-utils
RUN npm install
# RUN npm i --production

RUN npm install puppeteer-core chrome-aws-lambda --save-prod
RUN npm install puppeteer@1.14.0 --save-dev

VOLUME /student-grading-utils

ADD ${reference_image} .
COPY /bin/$checker /bin/
CMD chmod +x bin/$checker

ENTRYPOINT ./bin/$checker