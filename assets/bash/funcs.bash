#!/usr/bin/env bash

function trim(){
  if [[ -p /dev/stdin ]]; then
    echo -n "$(perl -pe 's/(^\s+|\s+\$)//g')";
  else
    echo -n "$(echo "$1" | perl -pe 's/(^\s+|\s+\$)//g')";
  fi;
};
