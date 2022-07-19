#!/bin/bash

# --- INSTALL DOCKER ---

apt install -y apt-transport-https ca-certificates gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
apt update
apt install -y docker-ce

# --- CTFD ---

# Create patch https://raw.githubusercontent.com/radys/CTFd/main/honeypot.patch
# git diff from-commit to-commit > output-file
# git diff 7d56e59 919b9d0 > ../honeypot.patch

apt install -y jq git
CTFD=$(curl -sL https://api.github.com/repos/CTFd/CTFd/releases/latest | jq -r ".tag_name")

cd /srv && git clone https://github.com/CTFd/CTFd.git && cd /srv/CTFd

### Version 3.4.3 -> 3.5.0, 20220719
### Patch SQLlite: https://github.com/CTFd/CTFd/commit/a2c81cb03a398f3ca1819642b8e8dba181dccb22
### !!! Remove hash after release new version > 3.5.0
### !!! git checkout $CTFD

# --- hCaptcha ---

cd /srv/CTFd/CTFd/plugins
git clone https://github.com/tamuctf/ctfd-recaptcha-plugin.git
echo "pip install -r CTFd/plugins/ctfd-recaptcha-plugin/requirements.txt" >> /srv/CTFd/prepare.sh

docker build --tag="radys/ctfd:latest" --tag="radys/ctfd:$CTFD" .

# --- CTFD HONEYPOT ---

curl https://raw.githubusercontent.com/radys/CTFd/main/honeypot.patch | git apply -v
docker build --tag="radys/ctfd:honeypot" --tag="radys/ctfd:honeypot-$CTFD" .
