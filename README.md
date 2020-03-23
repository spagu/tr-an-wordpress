# tr-an-wordpress
Terraform Ansible to GCP - deployment

### Config

- Create a Storage Bucket
- Change file `ansible/group_vars/all` - Change `server_hostname: NEEDS_TO_BE_SET` to use the static ip you have setup - Change `gcloud_bucket_name: NEEDS_TO_BE_SET` to use the bucket name you have created
- Change file `terraform/main` - Change `nat_ip = "NEEDS_TO_BE_SET"` to use the static ip you have setup

### Running

- run `terraform init`
- run `terraform apply`