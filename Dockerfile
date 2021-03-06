FROM debian:wheezy
MAINTAINER Zack Yang <zack9433@gmail.com>

RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    libpng-dev \
    python-software-properties \
    git \
    curl

USER root
ENV HOME /root
ENV NODE_INSTALL_VERSION v0.10.33
ENV RUBY_INSTALL_VERSION 2.1.2

# Install node.js and upgrade npm
RUN git clone https://github.com/creationix/nvm.git $HOME/.nvm
RUN /bin/bash -c "source ~/.nvm/nvm.sh && nvm install $NODE_INSTALL_VERSION && \
   nvm use ${NODE_INSTALL_VERSION} && nvm alias default $NODE_INSTALL_VERSION && \
   ln -s $HOME/.nvm/$NODE_INSTALL_VERSION/bin/node /usr/bin/node && \
   ln -s $HOME/.nvm/$NODE_INSTALL_VERSION/bin/npm /usr/bin/npm && \
   curl https://www.npmjs.org/install.sh | sh"

# Install ruby
RUN /bin/bash -c "git clone https://github.com/sstephenson/rbenv.git $HOME/.rbenv && \
                  git clone https://github.com/sstephenson/ruby-build.git $HOME/.rbenv/plugins/ruby-build"

RUN /bin/bash -c "echo 'export PATH=\$HOME/.rbenv/bin:$PATH' >> ~/.bash_profile && \
                        echo 'eval \"\$(rbenv init -)\"' >> ~/.bash_profile"

ENV PATH $HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH
# RUN echo PATH=$PATH

# Never install rubygem docs
RUN /bin/bash -c "rbenv init - && \
                  rbenv install $RUBY_INSTALL_VERSION && \
                  rbenv global $RUBY_INSTALL_VERSION && \
                  echo 'gem: --no-rdoc --no-ri' >> ~/.gemrc"
# Install bundler
RUN gem install bundler && rbenv rehash

# Install compass
RUN gem install compass

# Install staging server make file
VOLUME /root/.staging
VOLUME /root/project

# Setup ssh key and git config
RUN /bin/bash -c "mkdir .ssh && \
                  echo 'ssh-keygen -q -f ~/.ssh/id_rsa -N \"\" -t rsa' >> ~/.bash_profile && \
                  echo 'cat ~/.ssh/id_rsa.pub' >> ~/.bash_profile && \
                  echo 'echo -e \"Host github.com\n\tStrictHostKeyChecking no\n\" >> ~/.ssh/config' >> ~/.bash_profile && \
                  echo 'echo -e \"Host bitbucket.org\n\tStrictHostKeyChecking no\n\" >> ~/.ssh/config' >> ~/.bash_profile && \
                  echo 'git config --global url.\"https://\".insteadOf git://' >> ~/.bash_profile"

# Clean up
#RUN apt-get remove -y \
#    build-essential \
#    libpng-dev \
#    libssl-dev

ENTRYPOINT ["/bin/bash", "--login", "-i", "-c"]
WORKDIR $HOME

CMD ["bash"]
