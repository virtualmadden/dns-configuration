#!/usr/bin/env bash
# Creates an access key for the ses-smtp IAM user (mail.tf) and converts it to SES SMTP
# credentials. The password goes to the clipboard, never the terminal or Terraform state.
#
# Run with credentials for the shared services account:
#   AWS_PROFILE=shared-services-prod scripts/ses-smtp-credentials.sh
set -euo pipefail

user=ses-smtp
region=${AWS_REGION:-us-west-2}

command -v pbcopy >/dev/null || { echo "error: needs pbcopy (macOS)" >&2; exit 1; }

keys=$(aws iam list-access-keys --user-name "$user" --query 'length(AccessKeyMetadata)' --output text)
if [ "$keys" -ge 2 ]; then
  echo "error: $user already has two access keys; delete the one no client uses first:" >&2
  echo "  aws iam delete-access-key --user-name $user --access-key-id <id>" >&2
  exit 1
fi

read -r key_id secret < <(aws iam create-access-key --user-name "$user" \
  --query 'AccessKey.[AccessKeyId,SecretAccessKey]' --output text)

# SES SMTP password: an HMAC-SHA256 chain over the secret key, prefixed with version 0x04.
# https://docs.aws.amazon.com/ses/latest/dg/smtp-credentials.html
SECRET="$secret" REGION="$region" python3 -I -c '
import base64, hashlib, hmac, os
def sign(key, msg):
    return hmac.new(key, msg.encode(), hashlib.sha256).digest()
signature = sign(("AWS4" + os.environ["SECRET"]).encode(), "11111111")
for msg in (os.environ["REGION"], "ses", "aws4_request", "SendRawEmail"):
    signature = sign(signature, msg)
print(base64.b64encode(bytes([4]) + signature).decode(), end="")
' | pbcopy

cat <<OUT
SMTP server: email-smtp.$region.amazonaws.com
Port:        587 (TLS)
Username:    $key_id
Password:    copied to the clipboard
OUT
if [ "$keys" -ge 1 ]; then
  echo "Once every client uses the new key, delete the old one with: aws iam list-access-keys --user-name $user"
fi
