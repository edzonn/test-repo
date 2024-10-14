#!/bin/bash

# Get the load balancers' names and security groups
load_balancers_info=$(aws elb describe-load-balancers --query "LoadBalancerDescriptions[*].{Name:LoadBalancerName, SecurityGroups:SecurityGroups, LoadBalancerName:LoadBalancerName}" --output json)

# Parse the load balancer names from the JSON
load_balancer_names=$(echo $load_balancers_info | jq -r '.[].Name')

# Initialize an array to hold the final results
final_results=()

# Iterate over each load balancer name to get its tags
for lb_name in $load_balancer_names; do
    # Get the tags for the current load balancer
    tags=$(aws elb describe-tags --load-balancer-names $lb_name --query "TagDescriptions[0].Tags[?Key=='kubernetes.io/service-name'].Value" --output json)

    # Find the corresponding security groups
    security_groups=$(echo $load_balancers_info | jq -r ".[] | select(.Name==\"$lb_name\") | .SecurityGroups")

    # Construct the result for the current load balancer
    result=$(jq -n --arg Name "$lb_name" --argjson SecurityGroups "$security_groups" --argjson Tags "$tags" '{Name: $Name, SecurityGroups: $SecurityGroups, Tags: $Tags}')

    # Add the result to the final array
    final_results+=("$result")
done

# Convert the final results array to JSON
echo "${final_results[@]}" | jq -s

