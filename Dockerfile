FROM ubuntu:xenial

MAINTAINER artem_rozumenko@epam.com

ARG RUBY_VERSION=2.3.0-dev
ARG BANDIT_VERSION=1.5.1
ARG SPOTBUGS_VERSION=3.1.9

# For safety tool
ARG LC_ALL=C.UTF-8
ARG LANG=C.UTF-8

RUN apt-get -qq update && apt-get install -y --no-install-recommends software-properties-common
RUN add-apt-repository ppa:jonathonf/python-3.6 && apt-get -qq update
RUN apt-get -qq install -y --no-install-recommends default-jre default-jdk xvfb wget ca-certificates git gcc make \
            build-essential libssl-dev zlib1g-dev libbz2-dev libpcap-dev unzip \
            libreadline-dev libsqlite3-dev curl llvm libncurses5-dev libncursesw5-dev \
            xz-utils tk-dev libffi-dev liblzma-dev perl libnet-ssleay-perl python-dev python-pip \
            libxslt1-dev libxml2-dev libyaml-dev openssh-server  python-lxml wget \
            xdot python-gtk2 python-gtksourceview2 dmz-cursor-theme supervisor \
            python-setuptools maven && \
    pip install pip setuptools --upgrade && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists

# Installing NodeJS
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get -qq install -y --no-install-recommends nodejs
RUN npm -g i n && n 10.13.0 --test && npm -g i npm@6.1 http-server@0.11.1 retire@1.6.0 --test

# Installing python3 and pip
RUN apt-get -y --no-install-recommends install python3.6 python3.6-dev
RUN wget https://bootstrap.pypa.io/get-pip.py && python3.6 get-pip.py && ln -s /usr/bin/python3.6 /usr/local/bin/python3
RUN pip3 install pip --upgrade
RUN pip3 install setuptools  --upgrade
RUN pip3 --version

# Install pybandit (Python SAST tool)
RUN pip3 install bandit==${BANDIT_VERSION}

# Install safety (Python SAST composition analysis tool)
RUN pip3 install safety

# Install Spotbugs
WORKDIR /opt

RUN curl -LOJ http://repo.maven.apache.org/maven2/com/github/spotbugs/spotbugs/${SPOTBUGS_VERSION}/spotbugs-${SPOTBUGS_VERSION}.zip
RUN unzip spotbugs-${SPOTBUGS_VERSION}.zip
RUN rm -rf spotbugs-${SPOTBUGS_VERSION}.zip

ENV PATH $PATH:/opt/spotbugs-${SPOTBUGS_VERSION}/bin

# Install NodeJsScan
RUN pip3.6 install nodejsscan

# Installing ruby
RUN cd /tmp && \
    apt-get install -y  --no-install-recommends autoconf bison build-essential libssl-dev libyaml-dev \
                        libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev \
                        rbenv ruby-build
RUN rbenv install ${RUBY_VERSION} && rbenv global ${RUBY_VERSION}

# Install bakeman (Ruby SAST tool)
RUN gem install brakeman

ENV PATH /opt/jdk-10.0.2/bin:$PATH

WORKDIR /tmp
RUN mkdir /tmp/reports
COPY scan-config.yaml /tmp/scan-config.yaml

# Installing Dusty
RUN pip3 install git+https://github.com/reportportal/client-Python.git
RUN pip3 install git+https://github.com/carrier-io/dusty.git

ENTRYPOINT ["run"]
