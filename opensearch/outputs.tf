# create outputs for aws opensearch terraform module


output "opensearch_domain_arn" {
  value = module.opensearch.domain_arn
}

output "opensearch_domain_id" {
  value = module.opensearch.domain_id
}

output "opensearch_domain_name" {
  value = module.opensearch.domain_name
}

output "opensearch_domain_endpoint" {
  value = module.opensearch.domain_endpoint
}

output "opensearch_domain_kibana_endpoint" {
  value = module.opensearch.domain_kibana_endpoint
}

output "opensearch_domain_status" {
  value = module.opensearch.domain_status
}

output "opensearch_domain_elasticsearch_version" {
  value = module.opensearch.domain_elasticsearch_version
}

output "opensearch_domain_elasticsearch_cluster_config_instance_type" {
  value = module.opensearch.domain_elasticsearch_cluster_config_instance_type
}

output "opensearch_domain_elasticsearch_cluster_config_instance_count" {
  value = module.opensearch.domain_elasticsearch_cluster_config_instance_count
}

output "opensearch_domain_elasticsearch_cluster_config_dedicated_master_enabled" {
  value = module.opensearch.domain_elasticsearch_cluster_config_dedicated_master_enabled
}

output "opensearch_domain_elasticsearch_cluster_config_dedicated_master_type" {
  value = module.opensearch.domain_elasticsearch_cluster_config_dedicated_master_type
}

output "opensearch_domain_elasticsearch_cluster_config_dedicated_master_count" {
  value = module.opensearch.domain_elasticsearch_cluster_config_dedicated_master_count
}

