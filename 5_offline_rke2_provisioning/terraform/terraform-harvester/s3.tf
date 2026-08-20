terraform {
    backend "s3" {
        bucket = ""                  # Name of the S3 bucket
        endpoints = {
            s3 = "https://path/to/endpoint"   # Minio endpoint
        }
        key = "somename.tfstate"        # Name of the tfstate file
        access_key=""           # Access and secret keys
        secret_key=""
        region = ""                     # Region validation will be skipped
        skip_credentials_validation = true  # Skip AWS related checks and validations
        skip_requesting_account_id = true
        skip_metadata_api_check = true
        skip_region_validation = true
        use_path_style = true             # Enable path-style S3 URLs (https://<HOST>/<BUCKET> https://developer.hashicorp.com/terraform/language/settings/backends/s3#use_path_style
    }
}

