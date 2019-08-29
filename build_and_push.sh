# construct the ECR name.
account=$(aws sts get-caller-identity --query Account --output text)
region=$(aws configure get region)
fullname="${account}.dkr.ecr.${region}.amazonaws.com/quiltdata/sagemaker-demo:latest"

# If the repository doesn't exist in ECR, create it.
# The pipe trick redirects stderr to stdout and passes it /dev/null.
# It's just there to silence the error.
aws ecr describe-repositories --repository-names "quiltdata/sagemaker-demo" > /dev/null 2>&1

# Check the error code, if it's non-zero then know we threw an error and no repo exists
if [ $? -ne 0 ]
then
    aws ecr create-repository --repository-name "quiltdata/sagemaker-demo" > /dev/null
fi

# Get the login command from ECR and execute it directly
$(aws ecr get-login --region ${region} --no-include-email)

# Build the docker image, tag it with the full name, and push it to ECR
docker build  -t "quiltdata/sagemaker-demo" .
docker tag "quiltdata/sagemaker-demo" ${fullname}

docker push ${fullname}