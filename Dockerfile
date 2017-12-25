#usage:
# 1) build: sudo docker build -t ml . | tee dkr.log
# 2) run: sudo docker run -it ml
# 3) connect to the running one: sudo exec -it ml bash

FROM ubuntu:xenial


################## user dev #######################
# sudo
RUN apt -qy update \
  && apt -qy --no-install-recommends install sudo

# create user dev
RUN \
  adduser dev \
  && sudo adduser dev sudo \
  && echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN cat /etc/sudoers

# switch to user dev
USER dev
RUN cd $HOME


################### essential packages ############################
RUN \
  sudo apt -qy --no-install-recommends install \
    less \
    locate \
    tmux \
    htop iotop nmap \
    wget curl \
    file \
    ca-certificates \
    bzip2 \

    git \
    build-essential cmake clang \
    python-dev python3-dev \
    golang-go \
    vim emacs\

  && sudo apt -qy autoremove \
  && sudo apt -qy clean \
  && sudo rm -rf /var/lib/apt/lists/*
RUN sudo apt-get update
RUN sudo apt-get install -y software-properties-common
RUN sudo apt-get install -y apt-transport-https

RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4


######################## Anaconda ####################################
RUN \
#  wget --quiet https://repo.continuum.io/archive/Anaconda2-5.0.1-Linux-x86_64.sh -O ~/anaconda.sh \
  sudo wget --quiet https://repo.continuum.io/archive/Anaconda3-5.0.1-Linux-x86_64.sh -O ~/anaconda.sh \
  && sudo /bin/bash ~/anaconda.sh -b -p /opt/conda \
  && sudo rm ~/anaconda.sh

RUN \
  sudo /opt/conda/bin/conda install -c conda-forge tensorflow &&\
  sudo /opt/conda/bin/conda install -c conda-forge xgboost &&\
  sudo /opt/conda/bin/conda install -c conda-forge lightgbm &&\
  sudo /opt/conda/bin/conda install -c anaconda setuptools &&\
  sudo /opt/conda/bin/pip install deap &&\
  sudo /opt/conda/bin/pip install catboost &&\
  sudo /opt/conda/bin/pip install kaggle-cli &&\
  sudo /opt/conda/bin/pip install \
    virtualenv virtualenvwrapper \
    jedi flake8
  

####################### r-language #####################
RUN sudo add-apt-repository -y ppa:webupd8team/java
RUN sudo apt-get update
 
RUN sudo add-apt-repository 'deb https://ftp.ussg.iu.edu/CRAN/bin/linux/ubuntu xenial/'
RUN sudo apt-get update
RUN sudo apt-get install -y --allow-unauthenticated r-base
RUN sudo apt-get install -y r-base-dev
  
# Download and Install RStudio
RUN sudo apt-get install -y gdebi-core
RUN sudo wget https://download1.rstudio.org/rstudio-1.0.44-amd64.deb
RUN sudo gdebi rstudio-1.0.44-amd64.deb
RUN sudo rm rstudio-1.0.44-amd64.deb

# emacs for R 
#RUN \
#  git clone https://github.com/emacs-ess/ESS.git /home/dev/ESS \
#  && cd /home/dev/ESS && make && make install


##################### work with go ####################
RUN mkdir /home/dev/go && mkdir /home/dev/go/bin
ENV GOPATH /home/dev/go
ENV PATH $PATH:$GOPATH/bin
RUN go get -u github.com/nsf/gocode


######################### gcsfuse ######################
# For mounting Google Compute Storage buckets as directories
# sudo gcsfuse --key-file <path-to-key> <bucket-name> <local-path>
ENV GCSFUSE_REPO gcsfuse-xenial
RUN sudo -E echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | sudo tee /etc/apt/sources.list.d/gcsfuse.list
RUN sudo -E cat /etc/apt/sources.list.d/gcsfuse.list
RUN sudo -E curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
RUN sudo -E apt-get update
RUN sudo -E apt-get install -y gcsfuse


######################### gdrive ########################
# work with Google Drive from cli
RUN go get github.com/prasmussen/gdrive


####################### vim plugins ######################
# Install Vundle - package manager
# Reference https://github.com/VundleVim/Vundle.vim#quick-start
COPY ./inst.d/.vimrc /etc/vim/vimrc.local
RUN \
  sudo git config --global http.sslVerify false && \
  sudo git clone https://github.com/VundleVim/Vundle.vim.git \
    /usr/share/vim/bundle/Vundle.vim
RUN sudo -E vim +PluginInstall +qall

# Install YouCompleteMe - autocomplete for python(static),c++ ()
# Reference https://github.com/Valloric/YouCompleteMe#ubuntu-linux-x64
RUN sudo /opt/conda/bin/python /usr/share/vim/bundle/YouCompleteMe/install.py --clang-completer --gocode-completer
#######################################################################


# environment variables
RUN \
  sudo bash -c 'echo "export GOPATH=/home/dev/go" >> /etc/bash.basrc' &&\
  sudo bash -c 'echo "PATH=/opt/conda/bin:$GOPATH/bin:$PATH" >> /etc/bash.bashrc' 


# emacs configuration
#COPY ./inst.d/init.el /root/.emacs.d/init.el
#COPY ./inst.d/init.el /home/dev/.emacs.d/init.el


# privilegies for dev
RUN \
  sudo chown -R dev /etc/vim /home/dev \
  && sudo chgrp -R dev /etc/vim /home/dev 


