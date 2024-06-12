# create ec2 instance using pulumi

import pulumi
import pulumi_aws as aws

# create a security group
group = aws.ec2.SecurityGroup('webserver-secgrp',
    description='Enable HTTP access',
    ingress=[{
        'protocol': 'tcp',
        'from_port': 80,
        'to_port': 80,
        'cidr_blocks': ['0.0.0.0/0'],
    }],
)

# create ec2 instance

server = aws.ec2.Instance('webserver-www',
    instance_type='t2.micro',
    vpc_security_group_ids=[group.id],
    ami='ami-0d8f6eb4f641ef691',
)

# export the public ip of the instance
pulumi.export('public_ip', server.publi