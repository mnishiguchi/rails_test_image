# Using Ubuntu Xenial Xerus 16.04 LTS (this is a minimal image with curl and vcs tool pre-installed):
FROM buildpack-deps:xenial

# Add new user test_user
RUN adduser test_user

# Install sudo and add created user to sudoers without requirement to enter password:
RUN apt-get update && apt-get install -y sudo && rm -rf /var/lib/apt/lists/*
RUN echo "test_user ALL=(root) NOPASSWD:ALL" > /etc/sudoers

# Switch to created user and run further commands form its home directory:
USER test_user
WORKDIR /home/test_user

# Install dependencies:
RUN \
  sudo apt-get update \
  && sudo apt-get install -y \
    build-essential \
    chrpath \
    fonts-liberation \
    libappindicator1 \
    libasound2 \
    libfontconfig1 \
    libfreetype6 \
    libnss3-dev \
    libssl-dev \
    libxft-dev \
    libxss1 \
    lsb-release \
    tzdata \
    xdg-utils

# Install Phantomjs:
ENV PHANTOM_JS="phantomjs-2.1.1-linux-x86_64"
RUN \
  wget https://github.com/Medium/phantomjs/releases/download/v2.1.1/$PHANTOM_JS.tar.bz2 \
  && tar xvjf $PHANTOM_JS.tar.bz2 \
  && sudo mv $PHANTOM_JS /usr/local/share \
  && sudo ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/bin

# Install Chromium:
RUN sudo apt-get install -fy chromium-browser

# Install Chromedriver:
RUN \
  wget -O /tmp/chromedriver.zip https://chromedriver.storage.googleapis.com/2.45/chromedriver_linux64.zip \
  && sudo unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/

# Install RVM and explicitly export its executable path:
RUN \
  gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
  && \curl -sSL https://get.rvm.io | bash -s stable
ENV PATH=$PATH:/home/test_user/.rvm/bin:

# Install Ruby and explicitly export its executable path:
ENV RUBY_VERSION=2.6.0
RUN rvm install $RUBY_VERSION
ENV PATH=$PATH:/home/test_user/.rvm/rubies/ruby-$RUBY_VERSION/bin:

# Install NVM, Node and Yarn and explicitly export its executable path:
ENV NVM_VERSION=0.34.0
ENV NODE_VERSION=10.15.0
ENV YARN_VERSION=1.13.0
RUN \
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v$NVM_VERSION/install.sh | bash \
  && export NVM_DIR="$HOME/.nvm" \
  && [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" \
  && nvm install $NODE_VERSION \
  && nvm alias default $NODE_VERSION \
  && nvm use default \
  && npm install --global yarn@$YARN_VERSION
ENV PATH=$PATH:/home/test_user/.nvm/versions/node/v$NODE_VERSION/bin:
