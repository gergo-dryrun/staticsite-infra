# Quickstart Hosting Static Site on AWS Part 1: Infrastructure
###### Cloudformation stack suite to deploy static site behind cloudfront with optional test environment and WAF protection


This project includes a master CloudFormation template that bundles up independent stacks for:

 * Creating CloudFront distribution with s3 bucket as origin
 * Creates CloudFront Origin Access Identity to protect s3 bucket
 * [Optional] Creates WAF with a suite of security automations
 * [Optional] Creates IP restricted test environment

Additionaly includes separate template for:

 * Creating an ACM SSL certificate


#### Prerequisites

* Route53 hosted zone for the domain you want your static site to be hosted on. [1]
* Means to verify e-mail sent out by ACM. [2]

#### Setup
Deploy the acm-certificate.template stack first, make sure you do it in US East (N. Virginia).

[<img src="https://s3-eu-west-1.amazonaws.com/quickstart-cloudtrail-to-elasticsearch/cloudformation-launch-stack.png">](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/new?stackName=acm-certificate&templateURL=https://s3-eu-west-1.amazonaws.com/dryrun.cloud-resources/2017-04-09-getting-started-static-sites/template/acm-certificate.template)

![Certificate parameters](https://s3-eu-west-1.amazonaws.com/dryrun.cloud-resources/2017-04-09-getting-started-static-sites/screenshots/acm-certificate.png)

This will issue a certificate for both www.{domainName} and {domainName}

Grab the CertificateArn from Outputs tab and save it for the next step.

Deploy the master.template

[<img src="https://s3-eu-west-1.amazonaws.com/quickstart-cloudtrail-to-elasticsearch/cloudformation-launch-stack.png">](https://console.aws.amazon.com/cloudformation/home?#/stacks/new?stackName=staticsite-infra&templateURL=https://s3-eu-west-1.amazonaws.com/dryrun.cloud-resources/2017-04-09-getting-started-static-sites/template/master.template)

Quite a few parameters are needed, the defaults should be fine for most of them (if you want the full setup with WAF included)

![Master template](https://s3-eu-west-1.amazonaws.com/dryrun.cloud-resources/2017-04-09-getting-started-static-sites/screenshots/master.png)

Use the ACM Certificate ARN obtained from previous step.

If you don't want to use WAF then set Configure WAF to 'no' and keep in mind that the CloudFront Access Log Bucket has to exist before deploying this stack.

If you already have a WebACL with security automations configured, set Provision Security Atuomations to 'no' and use the id of the WebACL that you want to re-use.

To read more about the WAF Security Automations I recommend giving [aws security automation quickstart](https://aws.amazon.com/answers/security/aws-waf-security-automations/) a read through.

Once you launch the stack it can take up to 40 minutes for all the resources to create.

![Master output](https://s3-eu-west-1.amazonaws.com/dryrun.cloud-resources/2017-04-09-getting-started-static-sites/screenshots/master-output.png)


Depending whether you selected to also create a testing environment you will end up with 2 buckets:

* live.{DomainName}
* test.{DomainName}

Both of them have been configured with default IndexDocument: index.html

If you want to be more autonomous I recommend forking this repo and adjust the parameter files under /parameters/ folder.

Then you can just use the Makefile to deploy/update the stack:

```bash
# To create stack
make STACK_NAME=acm-certificate REGION=us-east-1 create
# To poll for events
make STACK_NAME=acm-certificate REGION=us-east-1 watch
# To see the stack outputs
make STACK_NAME=acm-certificate REGION=us-east-1 output
# To update the stack
make STACK_NAME=acm-certificate REGION=us-east-1 update
# To delete the stack
make STACK_NAME=acm-certificate REGION=us-east-1 delete
```

This works with any template that has an associated parameter file.

#### Tips & gotchas
If you visit the live site before the DNS has fully propagated within AWS CloudFront, you might get a 307 Temporary Redirect, so I recommend waiting 20-30 minutes before visiting the site after the stack has been deployed.

If you do end up with 307 and don't want to wait 24h for cloudfront cache to clear you will have to Create a `CloudFront invalidation`  for `*` to forceclear the DNS cache.

WAF can be a bit expensive if all you really host is a static site. Please make sure you check out the [Pricing model](https://aws.amazon.com/waf/pricing/) before deploying anything.

***

 [1] <http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/creating-migrating.html>

 [2] <http://docs.aws.amazon.com/acm/latest/userguide/setup-email.html>