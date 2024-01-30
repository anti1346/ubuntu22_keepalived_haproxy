#!/bin/bash

sudo apt-get update

sudo apt-get install -y lsb-release ca-certificates vim rsyslog openssh-server

sudo systemctl --now enable ssh.service

sudo systemctl status ssh.service
