# hubot-s3-brain

A re-packged 'port' of the [original community script](https://github.com/github/hubot-scripts/blob/master/src/scripts/s3-brain.coffee) used to store [Hubot's](https://hubot.github.com/) brain on Amazon S3.

Written by [Iristyle](https://github.com/Iristyle), re-packaged by [cspicer](https://github.com/cspicer).

# Configuration

Configuring the S3 brain is done via setting shell environment variables as follows:

Variable                            | Description
--------                            | -----------
`HUBOT_S3_BRAIN_ACCESS_KEY_ID`      | AWS Access Key ID with S3 permissions
`HUBOT_S3_BRAIN_SECRET_ACCESS_KEY`  | AWS Secret Access Key for ID
`HUBOT_S3_BRAIN_BUCKET`             | Bucket to store brain in
`HUBOT_S3_BRAIN_SAVE_INTERVAL`      | Optional auto-save interval in seconds, defaults to 30 mins

# Notes
Take care if using this brain storage with other brain storages. Others may set the auto-save interval to an undesireable value. Since S3 requests have an associated monetary value, this script uses a 30 minute auto-save timer by default to reduce cost.

It's highly recommended to use an [IAM account](https://console.aws.amazon.com/iam/home) explicitly for this purpose.

A sample S3 policy for a bucket named hubot-brain would look like:

    {
     "Statement": [
       {
         "Action": [
           "s3:DeleteObject",
           "s3:DeleteObjectVersion",
           "s3:GetObject",
           "s3:GetObjectAcl",
           "s3:GetObjectVersion",
           "s3:GetObjectVersionAcl",
           "s3:PutObject",
           "s3:PutObjectAcl",
           "s3:PutObjectVersionAcl"
         ],
         "Effect": "Allow",
         "Resource": [
           "arn:aws:s3:::hubot-bucket/brain-dump.json"
         ]
       }
     ]
    }

