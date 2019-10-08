<<<<<<< HEAD
FROM node:11-alpine

RUN set -x \
  && apk update \
  && apk upgrade \
  # replacing default repositories with edge ones
  && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" > /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
  \
  # Add the packages
  && apk add --no-cache dumb-init curl make gcc g++ python linux-headers binutils-gold gnupg libstdc++ nss chromium \
  \
  && npm install puppeteer@1.14.0 \
  \
  # Do some cleanup
  && apk del --no-cache make gcc g++ python binutils-gold gnupg libstdc++ \
  && rm -rf /usr/include \
  && rm -rf /var/cache/apk/* /root/.node-gyp /usr/share/man /tmp/* \
  && echo

RUN /bin/sh -c "apk add --no-cache bash"

WORKDIR /student-grading-utils
COPY . /student-grading-utils
COPY package.json /student-grading-utils
RUN npm install
# RUN npm i --production

# RUN npm install puppeteer-core chrome-aws-lambda --save-prod
# RUN npm install puppeteer@1.11.0 --save-dev


VOLUME /student-grading-utils


ADD ${reference_image} .
COPY /bin/$checker /bin/
CMD chmod +x bin/$checker


ENTRYPOINT ./bin/$checker
=======
// empty
>>>>>>> f281940f2c7e0e30de63deba7897e34bec1a91cc
