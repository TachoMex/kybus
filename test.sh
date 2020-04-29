#!/bin/sh -ex
base_dir=$(pwd)
for gem in ant-*; do
  cd $base_dir/$gem;
  bundle install
  bundle exec rake test
 
done;

cd $base_dir;
