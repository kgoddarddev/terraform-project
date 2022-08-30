
# IaaC (Terraform) Project


## Detail
###### Network
###### 4 Subnets (2 Private, 2 Public)
###### Internet GW
###### 2 Nat Gateways 
###### ALB 2 Host 
###### ASG Set to Maintain 2 Host in the Event of Failure/Crash/CPU 
## Security
###### SG for ALB
###### SB for Host -> ALB (Only)
## Connectivity
###### Bastion Host (in public)

![design](https://i.imgur.com/zAy5PYf.png)
