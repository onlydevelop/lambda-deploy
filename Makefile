init:
	cd terraform && terraform init

plan:
	cd terraform && terraform plan -var-file='main.tfvars'

apply:
	cd  terraform && terraform apply -var-file='main.tfvars'

destroy:
	cd terraform && terraform destroy 

test:
	aws lambda invoke --profile=lambda-deploy --region=ap-south-1 --function-name=example_lambda  lambda_response.txt
	@cat lambda_response.txt
	@rm lambda_response.txt
