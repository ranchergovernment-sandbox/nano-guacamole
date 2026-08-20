#!/bin/bash

envsubst <<EOF > ${basepath}/rke2-ansible/docs/${cluster_name}/post-deploy-manifests/100-dod-banner.yaml
apiVersion: management.cattle.io/v3
customized: false
default: '{}'
kind: Setting
metadata:
  name: ui-banners
source: ""
value: '{"loginError":{"message":"","showMessage":"false"},"bannerHeader":{"background":"#26a269","color":"#141419","textAlignment":"center","fontWeight":null,"fontStyle":null,"fontSize":"10px","textDecoration":null,"text":"UNCLASSIFIED//FOUO"},"bannerFooter":{"background":"#eeeff4","color":"#141419","textAlignment":"center","fontWeight":null,"fontStyle":null,"fontSize":"14px","textDecoration":null,"text":null},"bannerConsent":{"background":"#eeeff4","color":"#141419","textAlignment":"left","fontWeight":null,"fontStyle":null,"fontSize":"14px","textDecoration":null,"text":"                You
  are accessing a U.S. Government (USG) Information System (IS) that is provided for
  USG-authorized use only. By using this IS (which includes any device attached to
  this IS), you consent to the following conditions:\\n\\n\n                - The
  USG routinely intercepts and monitors communications on this IS for purposes including,
  but not limited to, penetration testing, COMSEC monitoring, network operations and
  defense, personnel misconduct (PM), law enforcement (LE), and counterintelligence
  (CI) investigations.\\n\n                - At any time, the USG may inspect and
  seize data stored on this IS.\\n\n                - Communications using, or data
  stored on, this IS are not private, are subject to routine monitoring, interception,
  and search, and may be disclosed or used for any USG authorized purpose.\\n\n                -
  This IS includes security measures (e.g., authentication and access controls) to
  protect USG interests--not for your personal benefit or privacy.\\n\n                -
  Notwithstanding the above, using this IS does not constitute consent to PM, LE or
  CI investigative searching or monitoring of the content of privileged communications,
  or work product, related to personal representation or services by attorneys, psychotherapists,
  or clergy, and their assistants. Such communications and work product are private
  and confidential. See User Agreement for details.","button":"ACCEPT"},"showHeader":"true","showFooter":"false","showConsent":"true"}'
EOF

