FROM ubuntu:17.04

RUN echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections



RUN apt update && \
    apt upgrade -y -qq && \
    apt install -y -qq curl openssh-server  git-core libgit2-dev build-essential sudo locales inotify-tools

RUN cd /tmp && \
    curl -O  https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
    dpkg -i erlang-solutions_1.0_all.deb && \
    rm /tmp/*.deb &&\
    apt update && \
    apt install -y -qq erlang=1:20.0-1 elixir=1.5.1-1

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt install -y -qq nodejs

RUN adduser --disabled-login --gecos 'Gitwerk' git && \
    sudo -u git -H git config --global core.autocrlf input && \
    sudo -u git -H git config --global gc.auto 0 && \
    sudo -u git -H git config --global repack.writeBitmaps true


RUN sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
RUN locale-gen && update-locale LC_ALL=en_US.UTF-8

RUN sudo -u git -H mix local.hex --force && \
    sudo -u git -H mix local.rebar --force

RUN mkdir -p /run/sshd
RUN echo "git ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/git-sudo-nopassword

ENV LANG en_US.UTF-8
EXPOSE 4000 2222
