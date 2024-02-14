#!/bin/bash

# Function to fetch logs for a specific category and namespace
fetch_logs() {
    category=$1
    namespace=$2
    logs=$(oc logs --since="$since_hours"h -n "$namespace" --selector=app="$category" --all-containers=true)
    echo "<div class='card mt-3'>"
    echo "<div class='card-header bg-primary text-white'><h5>${category^^} Logs in Namespace $namespace (Last $since_hours Hours)</h5></div>"
    echo "<div class='card-body'>"
    echo "<ul class='list-group list-group-flush'>"
    while IFS= read -r log_line; do
        echo "<li class='list-group-item'>$log_line</li>"
    done <<< "$logs"
    echo "</ul>"

    # Save logs to a file with timestamp and pod name
    timestamp=$(date +'%Y%m%d%H%M%S')
    logs_dir="pod_logs/logs_$timestamp"
    mkdir -p "$logs_dir"
    log_file="$logs_dir/${category}_${namespace}.log"
    echo "$logs" > "$log_file"
    echo "<a href='$log_file' download>Download Logs</a>"  # Add download link
    echo "</div></div>"
}

# Function to generate traffic flow diagram
generate_traffic_flow() {
    echo "<div class='card mt-3'>"
    echo "<div class='card-header bg-primary text-white'><h5>Traffic Flow Diagram (Dummy Data)</h5></div>"
    echo "<div class='card-body'>"
    echo "<div id='traffic-flow'>&#x1F6A8;</div>"  # Symbol for traffic flow
    # JavaScript code to generate the traffic flow diagram
    echo "<script>"
    echo "var nodes = [{id: 1, label: 'Source'}, {id: 2, label: 'Destination'}];"
    echo "var edges = [{from: 1, to: 2, label: 'Traffic'}];"  # Dummy edge
    echo "var container = document.getElementById('traffic-flow');"
    echo "var data = {nodes: nodes, edges: edges};"
    echo "var options = {}; var network = new vis.Network(container, data, options);"
    echo "</script>"
    echo "</div>"
}

# Function to check pod health
check_pod_health() {
    namespace=$1
    pods=$(oc get pods -n "$namespace" --no-headers)
    echo "<div class='col-md-4'>"
    echo "<div class='card mt-3'>"
    echo "<div class='card-header bg-primary text-white'><h5>Pod Health in Namespace $namespace</h5></div>"
    echo "<div class='card-body'>"
    echo "<ul class='list-group list-group-flush'>"
    while IFS= read -r pod_line; do
        # Extract pod name and status using shell parameter expansion
        pod_name="${pod_line%% *}"
        pod_status="${pod_line##* }"
        if [[ "$pod_status" == "Running" ]]; then
            color="text-success"
            pod_symbol="&#x2714;"  # Checkmark symbol for running pod
        elif [[ "$pod_status" == "Pending" || "$pod_status" == "ContainerCreating" ]]; then
            color="text-warning"
            pod_symbol="&#x23F3;"  # Hourglass symbol for pending pod
        else
            color="text-danger"
            pod_symbol="&#x274C;"  # Cross mark symbol for failed pod
        fi
        echo "<li class='list-group-item'><span class='$color'>$pod_symbol $pod_name: $pod_status</span></li>"
    done <<< "$pods"
    echo "</ul>"
    echo "</div></div></div>"
}

# Function to display node cluster health
display_node_cluster_health() {
    echo "<div class='card mt-3'>"
    echo "<div class='card-header bg-primary text-white'><h5>Node Cluster Health</h5></div>"
    echo "<div class='card-body'>"
    echo "Node cluster health summary here"
    echo "</div></div>"
}

# Function to display expiration dates
display_expiration_dates() {
    echo "<div class='card mt-3'>"
    echo "<div class='card-header bg-primary text-white'><h5>Expiration Dates</h5></div>"
    echo "<div class='card-body'>"
    echo "Expiration dates summary here"
    echo "</div></div>"
}

# Function to display CPU and memory health
display_cpu_memory_health() {
    echo "<div class='card mt-3'>"
    echo "<div class='card-header bg-primary text-white'><h5>CPU and Memory Health</h5></div>"
    echo "<div class='card-body'>"
    echo "CPU and memory health summary here"
    echo "</div></div>"
}

# Function to display log paths in table format
display_log_paths() {
    echo "<div class='card mt-3'>"
    echo "<div class='card-header bg-primary text-white'><h5>Log Paths</h5></div>"
    echo "<div class='card-body'>"
    echo "<table class='table table-bordered'>"
    echo "<thead><tr><th>Category</th><th>Namespace</th><th>Log Path</th></tr></thead>"
    echo "<tbody>"
    for namespace in "${namespaces[@]}"; do
        for category in "info" "debug" "trace"; do
            echo "<tr><td>${category^^}</td><td>$namespace</td><td>$(pwd)/pod_logs/logs_$timestamp/${category}_${namespace}.log</td></tr>"
        done
    done
    echo "</tbody></table></div></div>"
}

# Function to display Swagger UI links
display_swagger_ui_links() {
    echo "<div class='card mt-3'>"
    echo "<div class='card-header bg-primary text-white'><h5>Swagger UI Links</h5></div>"
    echo "<div class='card-body'>"
    echo "<ul class='list-group list-group-flush'>"
    for namespace in "${namespaces[@]}"; do
        pods=$(oc get pods -n "$namespace" --no-headers)
        while IFS= read -r pod_line; do
            # Extract pod name using shell parameter expansion
            pod_name="${pod_line%% *}"
            pod_hostname=$(oc get pod "$pod_name" -n "$namespace" -o=jsonpath='{.status.podIP}')
            echo "<li class='list-group-item'><a href='http://$pod_hostname:8080/swagger-ui/$namespace'>Swagger UI for $pod_name in $namespace</a></li>"
        done <<< "$pods"
    done
    echo "</ul></div></div>"
}

# Function to display OCP pod links in table format
display_ocp_pod_links() {
    echo "<div class='card mt-3'>"
    echo "<div class='card-header bg-primary text-white'><h5>OCP Pod Links</h5></div>"
    echo "<div class='card-body'>"
    echo "<table class='table table-bordered'>"
    echo "<thead><tr><th>Pod Name</th><th>Namespace</th><th>Link</th></tr></thead>"
    echo "<tbody>"
    for namespace in "${namespaces[@]}"; do
        pods=$(oc get pods -n "$namespace" --no-headers)
        while IFS= read -r pod_line; do
            # Extract pod name using shell parameter expansion
            pod_name="${pod_line%% *}"
            pod_hostname=$(oc get pod "$pod_name" -n "$namespace" -o=jsonpath='{.status.podIP}')
            echo "<tr><td>$pod_name</td><td>$namespace</td><td><a href='http://$pod_hostname'>Link</a></td></tr>"
        done <<< "$pods"
    done
    echo "</tbody></table></div></div>"
}

# HTML header
html_content="<html><head><title>Pod Logs, Traffic Flow & Pod Health</title>"
html_content+="<link href='https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css' rel='stylesheet'>"
html_content+="<style>.card {margin-bottom: 20px;}</style>"
html_content+="</head><body>"

# Read input parameters from user
echo "Please enter input parameters:"
read -p "Namespaces (separate multiple namespaces with spaces): " -a namespaces
read -p "Number of hours: " since_hours

# Create directory for pod logs
mkdir -p pod_logs

# Fetch and organize logs for each category and namespace
for namespace in "${namespaces[@]}"; do
    for category in "info" "debug" "trace"; do
        html_content+=$(fetch_logs "$category" "$namespace")
    done
done

# Generate traffic flow diagram (dummy data)
html_content+=$(generate_traffic_flow)

# Check pod health for each namespace
html_content+="<div class='col-md-4'>"
html_content+="<div class='row'>"
for namespace in "${namespaces[@]}"; do
    html_content+=$(check_pod_health "$namespace")
done
html_content+="</div>"
html_content+="</div>"

# Display node cluster health
html_content+=$(display_node_cluster_health)

# Display expiration dates
html_content+=$(display_expiration_dates)

# Display CPU and memory health
html_content+=$(display_cpu_memory_health)

# Display log paths in table format
html_content+=$(display_log_paths)

# Display Swagger UI links
html_content+=$(display_swagger_ui_links)

# Display OCP pod links in table format
html_content+=$(display_ocp_pod_links)

# HTML footer
html_content+="</div></div></body></html>"

# Save HTML content to a file
html_file="logs.html"
echo "$html_content" > "$html_file"

# Open HTML file in default web browser
xdg-open "$html_file" &>/dev/null
