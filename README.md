# aws-for-fluent-bit-config-from-env
AWS FireLens Fluent Bit image with an option to provide a custom config as an environment variable (`FLUENT_BIT_CONFIG_BASE64`) in base64 format

This customization won't be needed if either https://github.com/aws/containers-roadmap/issues/56 or https://github.com/aws/aws-for-fluent-bit/issues/521 is resolved

## Build and push

```
# Set vars
aws_region=REGION
ecr_domain="AWS_ACCOUNT_ID.dkr.ecr.$aws_region.amazonaws.com"
docker_image="$ecr_domain/custom-fluent-bit:latest"

# Build
docker build -t "$docker_image" .

# Push
aws ecr get-login-password --region "$aws_region" | docker login --username AWS --password-stdin "$ecr_domain"
docker push "$docker_image"
```

## Task definition example

```
{
  "family": "firelens-example-cloudwatch_logs",
  "taskRoleArn": "arn:aws:iam::AWS_ACCOUNT_ID:role/ecs_task_iam_role",
  "executionRoleArn": "arn:aws:iam::AWS_ACCOUNT_ID:role/ecs_task_execution_role",
  "networkMode": "awsvpc",
  "cpu": "256",
  "memory": "512",
  "requiresCompatibilities": [
    "FARGATE"
  ],
  "containerDefinitions": [
    {
      "essential": true,
      "name": "app",
      "image": "nginx",
      "logConfiguration": {
        "logDriver": "awsfirelens"
      },
      "memoryReservation": 100
    },
    {
      "essential": true,
      "name": "log_router",
      "image": "AWS_ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/custom-fluent-bit:latest",
      "command": [
        "/entrypoint_config_from_env.sh"
      ],
      "firelensConfiguration": {
        "type": "fluentbit",
        "options": {
          "config-file-type": "file",
          "config-file-value": "/fluent-bit/configs/config-from-env.conf"
        }
      },
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "firelens-container",
          "awslogs-region": "REGION",
          "awslogs-create-group": "true",
          "awslogs-stream-prefix": "firelens"
        }
      },
      "environment": [
        {
          "name": "FLUENT_BIT_CONFIG_BASE64",
          "value": "W09VVFBVVF0KICAgIE5hbWUgY2xvdWR3YXRjaF9sb2dzCiAgICBNYXRjaCAqCiAgICByZWdpb24gJHtGTFVFTlRfQklUX0xPR19SRUdJT059CiAgICBsb2dfa2V5IGxvZwogICAgbG9nX2dyb3VwX25hbWUgJHtGTFVFTlRfQklUX0xPR19HUk9VUH0KICAgIGxvZ19zdHJlYW1fcHJlZml4ICR7RkxVRU5UX0JJVF9MT0dfU1RSRUFNX1BSRUZJWH0KICAgIGF1dG9fY3JlYXRlX2dyb3VwIE9uCg=="
        },
        {
          "name": "FLUENT_BIT_LOG_REGION",
          "value": "REGION"
        },
        {
          "name": "FLUENT_BIT_LOG_GROUP",
          "value": "fluent-bit-cloudwatch"
        },
        {
          "name": "FLUENT_BIT_LOG_STREAM_PREFIX",
          "value": "from-fluent-bit-"
        }
      ],
      "memoryReservation": 50
    }
  ]
}
```
