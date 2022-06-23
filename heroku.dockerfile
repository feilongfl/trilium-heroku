FROM node:16.15.0-alpine

# Create app directory
WORKDIR /usr/src/app

RUN apk add --no-cache 

# Install app dependencies
# and get lasted release from github
RUN set -x \
    && apk add --no-cache --virtual .build-dependencies \
        autoconf \
        automake \
        g++ \
        gcc \
        libtool \
        make \
        nasm \
        libpng-dev \
        python3 \
        jq curl xz tar \
    && curl -L -e '; auto' `curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/zadam/trilium/releases/latest | jq -r '.assets[] | select(.name | startswith("trilium-linux-x64-server-")) | .browser_download_url'` | tar -Jxv --strip-components=1 \
    && cat package.json | grep -v electron > server-package.json \
    && cp server-package.json package.json \
    && rm -rv node_modules \
    && npm install --production \
    && apk del .build-dependencies

COPY config-heroku.ini config-heroku.ini

# USER node
CMD [ "/bin/sh", "-c", "mkdir ~/trilium-data && sed -r 's/@PORT/'$PORT'/' config-heroku.ini > ~/trilium-data/config.ini && node ./src/www" ]
