# infrastructure
Command used to import SSL certificate to AWS Certificate Manager:

aws acm import-certificate --certificate fileb://prod_csye6225dnsbagur_me.pem --certificate-chain fileb://prod_csye6225dnsbagur_me.ca-bundle --private-key fileb://private.key --region us-east-1 --profile prod
