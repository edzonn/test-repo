#!/bin/bash
ssh -i da-mlops-test-key.pem -L 27017:da-mlops-test-docdb.cluster-c4nv9fpmdvb9.ap-southeast-1.docdb.amazonaws.com:27017 -N ec2-user@da-mlops-test-lb-a57305a3b1c7dbf4.elb.ap-southeast-1.amazonaws.com -p 4545 &
sleep 5

python3 <<EOF
import pymongo
import json  
from bson import json_util

try:
    client = pymongo.MongoClient('mongodb://docdbadmin:docdbadmin@127.0.0.1:27017/?directConnection=true&serverSelectionTimeoutMS=2000&retryWrites=false&tls=true&tlsAllowInvalidHostnames=true&tlsCAFile=global-bundle.pem')

    db = client.admin

    # CREATE USER ADMIN ROLE
    # db.command("createUser", "admin", pwd="admin", roles=[{"role": "root", "db": "admin"}])

    # CREATE USER DATABASE ADMIN ROLE
    # db.command("createUser", "da-mlops-admin", pwd="admin", roles=[{"role": "dbAdmin", "db": "admin"}])

    # Create Users readonly
    # db.command("createUser", "da-mlops-readonly", pwd="readonly", roles=[{"role": "read", "db": "admin"}])

    # CREATE USER ONLY FOR SPECIFIC DATABASE[admin]
    # db.command("createUser", "da-mlops-readwrite", pwd="readwrite", roles=[{"role": "readWrite", "db": "admin"}])

    # DROP USER 
    db.command("dropUser", "admin")

    x = db.command("usersInfo", "admin")
    if x:
         print(json.dumps(x, indent=4, default=json_util.default))
         print("Execution successful")
    else:
        print("Document not found")

except pymongo.errors.ConnectionFailure as e:
    error_message = {
        "error_type": "ConnectionFailure",
        "error_message": str(e)
    }
    json_output = json.dumps(error_message, indent=4)
    print(json_output)
except pymongo.errors.OperationFailure as e:
    error_message = {
        "error_type": "OperationFailure",
        "error_message": str(e)
    }
    json_output = json.dumps(error_message, indent=4)
    print(json_output)
except Exception as e:
    error_message = {
        "error_type": "UnexpectedError",
        "error_message": str(e)
    }
    json_output = json.dumps(error_message, indent=4)
    print(json_output)
finally:
    # Close the MongoDB client
    client.close()
EOF

pkill -f 'ssh -i da-mlops-test-key.pem -L 27017:da-mlops-test-docdb.cluster-c4nv9fpmdvb9.ap-southeast-1.docdb.amazonaws.com:27017 -N ec2-user@da-mlops-test-lb-a57305a3b1c7dbf4.elb.ap-southeast-1.amazonaws.com -p 4545'
