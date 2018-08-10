#!/bin/bash
#
# Script to check site2site VPN connectivity between EC VPN server to AWS Prod & PreProd VPCs
# Run it as nohup /home/aws/vpncheck.sh > /tmp/vpncheck.out 2>&1 &
# IMP: Run the script manually to make sure it works fine. Run the ssh command manually and accept the keys, otherwise the script will wait at the ssh prompt FOREVER
#
ProdAlerted=0
PreprodAlerted=0
prodlink="EC - AWS Prod p2p OpenVPN"
preprodlink="EC - AWS PreProd p2p OpenVPN"
while true ; do
        echo `date`
        #if ! ssh -i /home/aws/oregon.pri.key centos@172.30.20.4 'uname -n' ; then
        if ! fping 172.30.20.4  ; then
                if [ $PreprodAlerted -eq 0 ] ; then
                        echo "Check $preprodlink. AWS vpn end point 172.30.20.4" | mail -s "Warning: $preprodlink" prashanth.namadev@nbcuni.com
                        PreprodAlerted=1
                fi
        else
                if [ $PreprodAlerted -eq 1 ] ; then
                        echo "$preprodlink recovered" | mail -s "Recovered: $preprodlink" prashanth.namadev@nbcuni.com ; fi
                PreprodAlerted=0
        fi

#        if ! ssh -i /home/aws/es1prod2018-infra.pem centos@172.31.19.163 'uname -n' ; then
         if ! fping 172.31.19.163 ; then
                if [ $ProdAlerted -eq 0 ] ; then
                        echo "Check $prodlink. AWS vpn end point 172.31.19.163" | mail -s "Warning: $prodlink" cnbc.infrastructure@nbcuni.com, cnbcsoftops@nbcuni.com
                        ProdAlerted=1
                fi
        else
                if [ $ProdAlerted -eq 1 ] ; then
                        echo "$prodlink recovered" | mail -s "Recovered: $prodlink" cnbc.infrastructure@nbcuni.com, cnbcsoftops@nbcuni.com ; fi
                ProdAlerted=0
        fi
        sleep 60
done
