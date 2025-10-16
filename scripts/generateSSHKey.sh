#!/bin/bash 

# Create Key for remote connections
hostname="$(hostname)"
if [[ ! -f ~/.ssh/$hostname ]]; then
  echo "No Remote SSH Key Present Generating one..."
  /usr/bin/ssh-keygen -t ed25519 -f ~/.ssh/$hostname -N ""
  touch ~/.ssh/authorized_keys && cat ~/.ssh/$hostname.pub >> ~/.ssh/authorized_keys
fi

# Create Key for Github Authentication
if [[ ! -f ~/.ssh/github ]]; then
  /usr/bin/ssh-keygen -t ed25519 -f ~/.ssh/github -N ""
  echo "New SSH Key generated. Upload add the public key below to Github before proceeding:"
  cat ~/.ssh/github.pub 

  read -p "Have you completed the upload (y/n)? " -n 1 -r 
  echo 
  if [[ $REPLY != 'y' ]]; then 
    echo $REPLY
    echo "Add the key in ~/.ssh/github.pub to Github and then run rebuild agian"
    exit 1 
  fi
fi
