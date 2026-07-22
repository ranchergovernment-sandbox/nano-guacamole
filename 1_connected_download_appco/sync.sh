#!/bin/bash

. ./env.sh
. ../versions

sync_product cert-manager ${CERT_MANAGER_VERSION}
sync_product harbor ${HARBOR_VERSION}
sync_product mariadb ${MARIADB_VERSION}
sync_product minio ${MINIO_VERSION}
sync_product keycloak ${KEYCLOAK_VERSION}
