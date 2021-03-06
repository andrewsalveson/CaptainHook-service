FROM ubuntu:14.04

MAINTAINER Nicholas Long nicholas.long@nrel.gov

# Run this separate to cache the download
ENV OPENSTUDIO_VERSION 1.14.0
ENV OPENSTUDIO_SHA 2181d73b03

# Download from S3
ENV OPENSTUDIO_DOWNLOAD_BASE_URL https://s3.amazonaws.com/openstudio-builds/$OPENSTUDIO_VERSION
ENV OPENSTUDIO_DOWNLOAD_FILENAME OpenStudio-$OPENSTUDIO_VERSION.$OPENSTUDIO_SHA-Linux.deb
ENV OPENSTUDIO_DOWNLOAD_URL $OPENSTUDIO_DOWNLOAD_BASE_URL/$OPENSTUDIO_DOWNLOAD_FILENAME

# Install gdebi, then download and install OpenStudio, then clean up.
# gdebi handles the installation of OpenStudio's dependencies including Qt5,
# Boost, and Ruby 2.0.

RUN apt-get update && apt-get install -y ca-certificates curl gdebi-core git \
    build-essential libssl-dev libreadline-dev zlib1g-dev libxml2-dev \
    && curl -SLO $OPENSTUDIO_DOWNLOAD_URL \
    && gdebi -n $OPENSTUDIO_DOWNLOAD_FILENAME \
    && rm -f $OPENSTUDIO_DOWNLOAD_FILENAME \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/local/lib/openstudio-$OPENSTUDIO_VERSION/ruby/2.0/openstudio/sketchup_plugin

# Build and install Ruby 2.0 using rbenv for flexibility
RUN git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
RUN RUBY_CONFIGURE_OPTS=--enable-shared ~/.rbenv/bin/rbenv install 2.0.0-p594
RUN ~/.rbenv/bin/rbenv global 2.0.0-p594

RUN echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
RUN echo 'eval "$(rbenv init -)"' >> ~/.bashrc

# Add bundler gem
RUN ~/.rbenv/shims/gem install bundler

# Add RUBYLIB link for openstudio.rb
ENV RUBYLIB /usr/local/lib/site_ruby/2.0.0

#ENV NODE_VERSION 0.10.41
ENV NODE_VERSION 7.0.0
ENV NPM_VERSION 2.14.1
#ENV NPM_VERSION latest
#ENV NODE_ENV production

RUN buildDeps='curl ca-certificates'
RUN set -x
RUN apt-get update && apt-get install -y $buildDeps --no-install-recommends
RUN rm -rf /var/lib/apt/lists/*
RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz"
RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc"
#RUN gpg --verify SHASUMS256.txt.asc
RUN grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
    && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1
RUN rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc
RUN apt-get purge -y --auto-remove $buildDeps
#RUN npm install -g npm@"$NPM_VERSION"
RUN npm install --production
RUN mv ./node_modules ./node_modules.tmp && mv ./node_modules.tmp ./node_modules && npm install
RUN npm install -g express-generator
RUN npm install -g forever
RUN npm cache clear
RUN mkdir /var/www
COPY ./package.json /var/www
RUN cd /var/www \
    && ls -l \
    && npm install express \
    && npm install
COPY . /var/www

EXPOSE 8080
#CMD [ "/usr/local/bin/node","/var/www/index.js" ]
CMD [ "forever","/var/www/index.js" ]


