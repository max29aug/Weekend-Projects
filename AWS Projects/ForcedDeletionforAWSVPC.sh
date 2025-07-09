#!/bin/bash

VPC_ID="EnterVPCIDHere"

echo "Starting forced deletion of VPC: $VPC_ID"

# Delete EC2 instances
echo "Terminating EC2 instances..."
INSTANCE_IDS=$(aws ec2 describe-instances --filters "Name=vpc-id,Values=$VPC_ID" --query "Reservations[].Instances[].InstanceId" --output text)
if [ -n "$INSTANCE_IDS" ]; then
  aws ec2 terminate-instances --instance-ids $INSTANCE_IDS
  aws ec2 wait instance-terminated --instance-ids $INSTANCE_IDS
fi

# Delete NAT Gateways
echo "Deleting NAT Gateways..."
NAT_GW_IDS=$(aws ec2 describe-nat-gateways --filter Name=vpc-id,Values=$VPC_ID --query "NatGateways[].NatGatewayId" --output text)
for nat in $NAT_GW_IDS; do
  aws ec2 delete-nat-gateway --nat-gateway-id $nat
done

# Release Elastic IPs
echo "Releasing Elastic IPs..."
EIP_ALLOC_IDS=$(aws ec2 describe-addresses --query "Addresses[?VpcId=='$VPC_ID'].AllocationId" --output text)
for eip in $EIP_ALLOC_IDS; do
  aws ec2 release-address --allocation-id $eip
done

# Delete Endpoints
echo "Deleting VPC Endpoints..."
ENDPOINT_IDS=$(aws ec2 describe-vpc-endpoints --filters Name=vpc-id,Values=$VPC_ID --query "VpcEndpoints[].VpcEndpointId" --output text)
for eid in $ENDPOINT_IDS; do
  aws ec2 delete-vpc-endpoints --vpc-endpoint-ids $eid
done

# Detach and delete Internet Gateway
echo "Detaching and deleting Internet Gateway..."
IGW_ID=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query "InternetGateways[].InternetGatewayId" --output text)
if [ -n "$IGW_ID" ]; then
  aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
  aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID
fi

# Delete route tables (excluding main)
echo "Deleting non-main Route Tables..."
ROUTE_TABLES=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" --query "RouteTables[?Associations[?Main==\`false\`]].RouteTableId" --output text)
for rtb in $ROUTE_TABLES; do
  aws ec2 delete-route-table --route-table-id $rtb
done

# Delete custom Network ACLs
echo "Deleting custom Network ACLs..."
NACL_IDS=$(aws ec2 describe-network-acls --filters "Name=vpc-id,Values=$VPC_ID" --query "NetworkAcls[?IsDefault==\`false\`].NetworkAclId" --output text)
for nacl in $NACL_IDS; do
  aws ec2 delete-network-acl --network-acl-id $nacl
done

# Delete custom Security Groups
echo "Deleting custom Security Groups..."
SG_IDS=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" --query "SecurityGroups[?GroupName!='default'].GroupId" --output text)
for sg in $SG_IDS; do
  aws ec2 delete-security-group --group-id $sg
done

# Delete Subnets
echo "Deleting Subnets..."
SUBNET_IDS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[].SubnetId" --output text)
for subnet in $SUBNET_IDS; do
  aws ec2 delete-subnet --subnet-id $subnet
done

# Delete VPC Peering Connections
echo "Deleting VPC Peering Connections..."
PEERING_IDS=$(aws ec2 describe-vpc-peering-connections --filters "Name=requester-vpc-info.vpc-id,Values=$VPC_ID" --query "VpcPeeringConnections[].VpcPeeringConnectionId" --output text)
for peer in $PEERING_IDS; do
  aws ec2 delete-vpc-peering-connection --vpc-peering-connection-id $peer
done

# Delete Network Interfaces
echo "Deleting Network Interfaces..."
ENI_IDS=$(aws ec2 describe-network-interfaces --filters "Name=vpc-id,Values=$VPC_ID" --query "NetworkInterfaces[].NetworkInterfaceId" --output text)
for eni in $ENI_IDS; do
  aws ec2 delete-network-interface --network-interface-id $eni
done

# Delete any remaining flow logs
echo "Deleting VPC Flow Logs..."
FLOW_LOG_IDS=$(aws ec2 describe-flow-logs --filter Name=resource-id,Values=$VPC_ID --query "FlowLogs[].FlowLogId" --output text)
for flowlog in $FLOW_LOG_IDS; do
  aws ec2 delete-flow-logs --flow-log-ids $flowlog
done

# Finally, delete the VPC
echo "Deleting VPC..."
aws ec2 delete-vpc --vpc-id $VPC_ID

echo "VPC $VPC_ID and its dependencies have been deleted."
