# create variables

variables "name" {
    type = "string"
}

variables "location" {
    type = "string"
}

variables "zone_id" {
    type = "string"
}

variables "type" {
    type = "string"
}

variables "ttl" {
    type = "number"
}

variables "records" {
    type = "list"
}