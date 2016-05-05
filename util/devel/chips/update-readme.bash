#!/bin/bash

cat README.md.in > README.md

for name in `ls -v [0-9]*.rst`
do
  echo $name
  title=`head -n 10 $name | grep -e '^[A-Za-z]' | head -n 1`
  echo "* [$title]($name)" >> README.md
done

echo >> README.md

