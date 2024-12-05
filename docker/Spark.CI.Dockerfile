FROM ubuntu:24.04

# 3.11.7
ARG PYTHON_VERSION=3.9.16
ARG SPARK_VERSION=3.5.0
ARG HADOOP_VERSION=3.3.5
ARG JAVA_VERSION=11.0.24-zulu

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    curl \
    zip \
    unzip \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    llvm \
    libncurses5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install pyenv
RUN curl https://pyenv.run | bash

# Set up pyenv environment variables
ENV PYENV_ROOT /root/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

# Install Python using pyenv
RUN pyenv install ${PYTHON_VERSION} && \
    pyenv global ${PYTHON_VERSION} && \
    pyenv rehash

# Install sdkman
RUN curl -s "https://get.sdkman.io" | bash

# Install Java, Spark, and Hadoop using sdkman
RUN bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && \
    sdk install java ${JAVA_VERSION} && \
    sdk use java ${JAVA_VERSION} && \
    sdk install spark ${SPARK_VERSION} && \
    sdk use spark ${SPARK_VERSION}"
    # && \
    # sdk install hadoop ${HADOOP_VERSION} && \
    # sdk use hadoop ${HADOOP_VERSION}"

# Set up environment variables
ENV JAVA_HOME=/root/.sdkman/candidates/java/current
ENV SPARK_HOME=/root/.sdkman/candidates/spark/current
# ENV HADOOP_HOME=/root/.sdkman/candidates/hadoop/current
ENV PATH=$PATH:$JAVA_HOME/bin:$SPARK_HOME/bin:$SPARK_HOME/sbin
# :$HADOOP_HOME/bin

# Set up Python
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install --user pipx && \
    python3 -m pipx ensurepath
ENV PATH="/root/.local/bin:$PATH"

RUN pipx install poetry==1.8.4

# Verify installations with detailed version output and error handling
RUN echo "Verifying installations..." && \
    java -version || exit 1 && \
    python3 --version || exit 1 && \
    spark-submit --version || exit 1 && \
    poetry -V || exit 1
