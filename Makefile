STACK:=$(subst _,-,$(STACK_NAME))
TEMPLATE:=template/$(STACK_NAME).template
PARAMETERS:=parameters/$(STACK_NAME).json
AWS_REGION:=$(REGION)
AWS_PROFILE:=default

create:
	@which aws || pip install awscli
	aws cloudformation create-stack --stack-name $(STACK) --template-body file://`pwd`/$(TEMPLATE) --parameters file://`pwd`/$(PARAMETERS) --capabilities CAPABILITY_IAM --profile $(AWS_PROFILE) --region $(AWS_REGION)

update:
	aws cloudformation update-stack --stack-name $(STACK) --template-body file://`pwd`/$(TEMPLATE) --parameters file://`pwd`/$(PARAMETERS) --capabilities CAPABILITY_IAM --profile $(AWS_PROFILE) --region $(AWS_REGION)

events:
	aws cloudformation describe-stack-events --stack-name $(STACK) --profile $(AWS_PROFILE) --region $(AWS_REGION)

watch:
	watch --interval 10 "bash -c 'make events | head -25'"

output:
	@which jq || ( which brew && brew install jq || which apt-get && apt-get install jq || which yum && yum install jq || which choco && choco install jq)
	aws cloudformation describe-stacks --stack-name $(STACK) --profile $(AWS_PROFILE) --region $(AWS_REGION) | jq -r '.Stacks[].Outputs'

delete:
	aws cloudformation delete-stack --stack-name $(STACK) --profile $(AWS_PROFILE) --region $(AWS_REGION)
