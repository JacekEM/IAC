# static web on aws


Terraform code which deploys infrastructure to supports
static website hosting on aws s3, as well as deployment.

Code is pulled from github repo and once build is trigged it
gets synced with s3 bucket. 

Either IAM role or access/secret keys are required for provisioning.



**AWS**
Terraform will create the following resources:

  - public s3 bucket.
  - bucket policy.
  - code_build project.
  - Service role for codebuild
  - IAM policy for service role.


**Variables**

__stored in variables.tf file__


**Other req**

  - buildscpec.yml file in the root of web_app repo
