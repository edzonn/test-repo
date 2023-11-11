import pymongo

try:
    client = pymongo.MongoClient('mongodb://docdbadmin:docdbadmin@127.0.0.1:27017/?directConnection=true&serverSelectionTimeoutMS=2000&retryWrites=false&tls=true&tlsAllowInvalidHostnames=true&tlsCAFile=global-bundle.pem')

    db = client.test
    col = db.test

    col.insert_one({'test': 'test'})

    x = col.find_one({'test': 'test'})

    if x:
        print(x)
        print("Document found")
    else:
        print("Document not found")

    client.close()

except pymongo.errors.ConnectionFailure as e:
    print(f"Connection error: {e}")
except pymongo.errors.OperationFailure as e:
    print(f"MongoDB operation error: {e}")
except Exception as e:
    print(f"An unexpected error occurred: {e}")


