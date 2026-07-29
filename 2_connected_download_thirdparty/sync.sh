#!/bin/bash
. ./env.sh
for i in `ls | grep -v .sh`;do
  sync_product $i
done

