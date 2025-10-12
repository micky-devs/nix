#!/bin/bash 

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
