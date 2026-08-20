#!/bin/bash

## Requirements:
# 1 - Linux Bastionhost (recommended) or Windows Workstation with WSLv2 ()
# 2 - Enough Storage: 120GB recommended for good measure for a specific partition path (like /opt/rancher/hauler). The script will use the location in which it was executed to store the images for Hauler.
# 3 - Carbide License (Username and password to access rgcrprod.azurecr.us)

## Documentation/References:
# Hauler quickstart guide = https://docs.hauler.dev/docs/introduction/quickstart
# Windows WLS = https://learn.microsoft.com/en-us/windows/wsl/install


## Script use ##
# Adjust the chart versions under the "Create Helm Chart Stores manifest" & "Pull & Store" sections if specific versions of cert-manager, rancher, airgapped-docs, heimdall2, stigatron, or stigatron-ui are needed.
# Copy this script to a jumpbox or bastion host.
# Run this script on the jumpbox or bastion host...Example: sh carbide-hauler-ag.sh 

# Variables

#RKE2
export RKE2_MAJOR=1.35
export RKE2_MINOR=6

#Rancher
export RANCHERVER=2.14.3

#Hauler Release
export vHauler=1.4.2

#Longhorn
export LONGHORNVER=v1.11.1

#Cert Manager
export CERTMANAGERVER=1.20.2

#Kubectl
export KUBECTLVER=v1.30.0

#Operating system info
export OS=centos
export OS_VER=9
export OS_ARCH=x86_64

#Container Releases
export platform=linux
export arch=amd64

#versions for create repo
export repodir=/etc/yum.repos.d/
export rke2_rpm_channel=stable
export rpm_site=rpm.rancher.io
export rpm_site_infix=${OS}/${OS_VER}
export rke2_majmin=${RKE2_MAJOR}

#These are derived from the variables above
export RKE2VER=v${RKE2_MAJOR}.${RKE2_MINOR}+rke2r1
export RKE2RPMVER=${RKE2_MAJOR}.${RKE2_MINOR}~rke2r1-0.el9.x86_64
export RKE2VERURL=v${RKE2_MAJOR}.${RKE2_MINOR}%2Brke2r1
