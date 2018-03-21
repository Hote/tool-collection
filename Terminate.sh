#!/bin/bash
#!/usr/bin/python
# -*- coding: utf-8 -*- 
##Author: Amos Lin
##Date: data
##Purpose:purpose
##[Todo]

profile=Production
#profile=Staging

# Search instance with specific criteria
SearchCriteria () {
read -p "Instance Searching Criteria " criteria
# modify from -i to -E to support multiple search criterial 
#aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,Tags[?Key==`Name`].Value[]]' --output text | sed 's/None$/None\n/' | sed '$!N;s/\n/ /' |grep -i $criteria > instances-list
aws ec2 describe-instances --profile $profile --query 'Reservations[].Instances[].[InstanceId,Tags[?Key==`Name`].Value[]]' --output text | sed 's/None$/None\n/' | sed '$!N;s/\n/ /' |grep -E $criteria > instances-list

cat instances-list |awk '{print $1}' >instances-list2

}
# This Section disable termination
DisableTermination () {
        for instances in `cat instances-list2`
        do
                echo $instances
                aws ec2  modify-instance-attribute --profile $profile --instance-id $instances --no-disable-api-termination
        done

}

# This section will terminate instance
TerminateInstance () {
        for i in `cat instances-list2`
        do
                echo "Terminating $i"
                aws ec2 terminate-instances --profile $profile --instance-ids $i
        done
}

# Stop EC2 Instances
# 
StopInstance () {
        for i in `cat instances-list2`
        do
                echo "Stop $i"
                aws ec2 stop-instances --profile $profile --instance-ids $i
        done
}

# Start EC2 Instances
# 
StartInstance () {
        for i in `cat instances-list2`
        do
                echo "Start $i"
                aws ec2 start-instances --profile $profile --instance-ids $i
        done
}


GetLoadBlancer(){
Read -p "Instance Query Criteria " criteria
aws elb  --profile $profile describe-load-balancers --load-balancer-name $criteria 
}

case $1 in
--search)
SearchCriteria
;;
--disabletermination)
DisableTermination
;;
--Terminate)
TerminateInstance
;;
--Stop)
StopInstance
;;
--Start)
StartInstance
;;
--GetLoadBlancer)
GetLoadBlancer
;;
*)
echo "Invalid Argument
Possible Values :
--search = Search Instances
--disabletermination = Disable Termination
--Terminate = Terminate Instances
--Start = Start EC2 instances
--Stop = Stop EC2 Instances
--GetLoadBlancer = Get Infomation of EC2 LoadBlancer
"
;;
esac
