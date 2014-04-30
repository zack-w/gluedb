#!/bin/bash

for f in app/models/*.rb; do
  cat "$f" | grep -E "^\s*class|^\s*field|^\s*embed|^\s*has|^\s*belong"
  echo -n -e "\n"
done
