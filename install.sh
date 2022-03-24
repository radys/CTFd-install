#!/bin/bash

apt install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
apt update
apt install -y docker-ce

# ---

# Create patch https://raw.githubusercontent.com/radys/CTFd/main/honeypot.patch
# git diff from-commit to-commit > output-file
# git diff 7d56e59 919b9d0 > ../honeypot.patch

apt install -y jq curl git
CTFD=$(curl -sL https://api.github.com/repos/CTFd/CTFd/releases/latest | jq -r ".tag_name")

cd /srv && git clone https://github.com/CTFd/CTFd.git && cd /srv/CTFd
git checkout $CTFD

docker build --tag="radys/ctfd:latest" --tag="radys/ctfd:$CTFD" .

curl https://raw.githubusercontent.com/radys/CTFd/main/honeypot.patch | git apply -v
docker build --tag="radys/ctfd:honeypot" --tag="radys/ctfd:honeypot-$CTFD" .
