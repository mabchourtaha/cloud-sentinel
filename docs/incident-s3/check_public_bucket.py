import boto3
import sys

def check_bucket_public(bucket_name, region="eu-west-1"):
    s3 = boto3.client("s3", region_name=region)

    try:
        status = s3.get_bucket_policy_status(Bucket=bucket_name)
        is_public = status["PolicyStatus"]["IsPublic"]
    except s3.exceptions.ClientError:
        is_public = False

    pab = s3.get_public_access_block(Bucket=bucket_name)["PublicAccessBlockConfiguration"]
    block_active = all(pab.values())

    if is_public or not block_active:
        print(f"WARNING: bucket '{bucket_name}' may be publicly accessible")
        print(f"  Policy is public: {is_public}")
        print(f"  Block Public Access fully enabled: {block_active}")
        sys.exit(1)
    else:
        print(f"OK: bucket '{bucket_name}' is not publicly exposed")
        sys.exit(0)

if __name__ == "__main__":
    check_bucket_public(sys.argv[1])