#!/bin/bash
#Download and convert the DoD CA Certs from Military CAC to make a one button deployment of keycloak
cert_url=https://militarycac.com/maccerts/AllCerts.zip
rm -fr certs_der
mkdir certs_der
curl -o AllCerts.zip ${cert_url}
cd certs_der
unzip ../AllCerts.zip
cd ..
mkdir certs_pem
IFS=$'\n\t'
for i in `ls certs_der`;do
	outcert=`echo ${i} | sed -e "s/ /_/g" | sed -e "s/.cer/.pem/g"`
	openssl x509 -inform der -in certs_der/${i} -out certs_pem/${outcert}
	#Function to catch the certs that are already pem
	if [ $? -ne 0 ];then
		openssl x509 -in certs_der/${i} -out certs_pem/${outcert}
	fi
done

