#!/bin/bash
. ./env.sh
for i in `ls artifacts`;do
  sync_product $i
done

