# Docker Backups to Amazon S3
This image is an always-on solution to automatically back up mounted volumes to S3.

## Environment Variables
Variables without default are required.

**`AWS_ACCESS_KEY_ID`**
- Your IAM user key.

**`AWS_SECRET_ACCESS_KEY`**
- Your IAM user secret.

**`AWS_DEFAULT_REGION`**
- The AWS region your S3 bucket is hosted in.

**`CRON_SCHEDULE`**
- **Default:** `0 * * * *` (Every hour)
- Standard cron format. How often to run back ups.

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
