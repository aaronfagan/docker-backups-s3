# Docker Backups to Amazon S3
This image is an always-on solution to automatically back up mounted volumes to Amazon S3.

## Environment Variables
Variables without default are required.

**`APP_NAME`**
- The name of your application.

**`AWS_ACCESS_KEY_ID`**
- **Note:** Required only if not hosting on AWS, or not using Amazon EC2 IAM roles.
- Your IAM user key.

**`AWS_SECRET_ACCESS_KEY`**
- **Note:** Required only if not hosting on AWS, or not using Amazon EC2 IAM roles.
- Your IAM user secret.

**`AWS_DEFAULT_REGION`**
- The AWS region your S3 bucket is hosted in.

**`DIR_BACKUP`**
- The directory on your container that you want to backup.

**`DIR_MOUNT`**
- The directory on your host that you want to backup.

**`CRON`**
- Standard cron format. How often to run back ups.

**`S3_PATH`**
- **Example:** `s3://my-bucket/path/to/backups`
- The AWS S3 bucket URL and path to upload backups to.

**`TZ`**
- Your preferred timezone.

## IAM Policy (Example)
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "route53:GetChange",
                "route53:ListHostedZonesByName"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "route53:ChangeResourceRecordSets"
            ],
            "Resource": [
                "arn:aws:route53:::hostedzone/YOUR_HOSTED_ZONE_ID"
            ]
        }
    ]
}
```

# Contributors
* Aaron Fagan - [Github](https://github.com/aaronfagan), [Website](https://www.aaronfagan.ca/)
