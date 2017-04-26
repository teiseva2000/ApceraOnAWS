#!/bin/sh

# Run this script to regenerate all terraform modules based on the
# content of vpc-layout.rb

for template in *.erb; do FILE=`echo $template | sed -e s/\.erb//`; erb -T 1 $template > $FILE; done

cd ../compute-resource-with-tags
rm vpc-layout.rb
ln -s ../multi-vpc/vpc-layout.rb .
for template in *.erb; do FILE=`echo $template | sed -e s/\.erb//`; erb -T 1 $template > $FILE; done
