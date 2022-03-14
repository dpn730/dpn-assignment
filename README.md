This was the requirement: https://gist.github.com/timtsoi-crypto/eaf558f00fbe55c0f6635ba2bf0c6511

For this exercise, I attempted to do Level 3.

Steps:
1. Configure AWS profile
2. Run `terraform init` before executing code.
3. Run `terraform apply` to deploy.

Remarks:
I setup the module and code as follows:
1. A public subnet (Level 1) needs to be deployed in order to deploy private subnets (Level 2)
2. A public and private subnet (Level 1 and 2) need to be deployed in order to deploy custom subnets (Level 3). This is because the custom zones make use of the existing internet gateway and NAT gateways that are created in Levels 1 and 2.

The rest of the description can be found in the comments in the module and main.tf