#!/bin/bash

platform=linux/amd64

function sync_product {
	mkdir -p artifacts/${1}
	pushd artifacts/${1}
	hauler store sync -f product.yaml
	popd

}

function upload_product {
	pushd artifacts/${1}
	hauler store copy registry://${offline_registry}
	if [ $? -ne 0 ];then
		echo fail
		exit 1
	fi
	popd
}


