For this exercise, I attempted to do Level 3.

I setup the module and code as follows:
1. A public subnet (Level 1) needs to be deployed in order to deploy private subnets (Level 2)
2. A public and private subnet (Level 1 and 2) need to be deployed in order to deploy custom subnets. This is because the custom zones make use of the existing internet gateway and NAT gateways that are created in Levels 1 and 2.

The rest of the description can be found in the comments in the module and main.tf