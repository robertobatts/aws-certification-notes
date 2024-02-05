# AWS CLI
To access AWS by Command Line Interface, we need access keys, which are generated through Amazon Console.

AWS CLI allows you to:
- Have direct access to the public APIs of AWS services
- Develop script to manage resources
- It's an alternative to using the AWS Management Console

## Setup CLI
1. Download and install following the instructions here https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
2. Open the terminal and type `aws --version` to check it has been correctly installed
3. Generate Acces Key from AWS Management Console
4. Execute `aws configure` and insert access key id and secret access key

## AWS CloudShell
You can use the CLI directly from AWS Cloudshell. CloudShell provide a shell where you also have access to the filesystem. The files you create in this shell are persisted between accesses, and they can be easily downloaded from the UI.