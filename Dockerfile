FROM public.ecr.aws/lambda/python:3.8
COPY requirements.txt .

# Copy function code

RUN pip3 install -r requirements.txt --target "${LAMBDA_TASK_ROOT}"
COPY . ${LAMBDA_TASK_ROOT}

# Command to run the Lambda function
CMD [ "helloworld.lambda_handler" ] 