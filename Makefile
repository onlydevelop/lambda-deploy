init:
	cd terraform && terraform init

plan:
	cd terraform && terraform plan -var-file='main.tfvars'

apply:
	cd  terraform && terraform apply -var-file='main.tfvars'

destroy:
	cd terraform && terraform destroy 
