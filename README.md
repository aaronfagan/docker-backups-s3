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

**`CREATE_LATEST`**
- Whether to create a `/latest` folder at your `S3_PATH`, with your most recent backup.

**`CRON`**
- **Default:** `0 0 * * *` (Daily, midnight)
- Standard cron format. How often to run backups.

**`S3_PATH`**
- **Example:** `s3://my-bucket/path/to/backups`
- The AWS S3 bucket URL and path to upload backups to.

**`TZ`**
- Your preferred timezone.

## IAM Policy (Example)
```
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action":[
            "s3:ListAllMyBuckets"
         ],
         "Resource":"arn:aws:s3:::*"
      },
      {
         "Effect":"Allow",
         "Action":[
            "s3:ListBucket",
            "s3:GetBucketLocation"
         ],
         "Resource":"arn:aws:s3:::examplebucket"
      },
      {
         "Effect":"Allow",
         "Action":[
            "s3:PutObject"
         ],
         "Resource":"arn:aws:s3:::examplebucket/*"
      }
   ]
}
```

# Contributors
* Aaron Fagan - [Github](https://github.com/aaronfagan), [Website](https://www.aaronfagan.ca/)
