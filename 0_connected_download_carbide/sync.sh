#!/bin/bash

. ./env.sh
. ../versions

sync_product rke2 ${RKE2_VERSION}

sync_product rancher ${RANCHER_VERSION}

sync_product airgapped-docs ${AIRGAP_DOCS_VERSION}

sync_product harvester ${HARVESTER_VERSION}

sync_charts rancher rancher ${RANCHER_CHART_VERSION} oci://registry.ranchercarbide.dev/carbide-charts

sync_charts rancher rgs-stig-profiles ${RANCHER_CHART_VERSION} oci://registry.ranchercarbide.dev/carbide-charts

sync_charts airgapped-docs airgapped-docs ${AIRGAP_DOCS_CHART_VERSION} oci://registry.ranchercarbide.dev/carbide-charts
