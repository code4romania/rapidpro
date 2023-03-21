variable "name" {
  description = "Name to be used throughout the resources"
  type        = string
}

variable "allowed_secrets" {
  description = "The AWS Secrets which can be accessed by the task definition"
  type        = list(string)
  default     = null
}

variable "additional_policy" {
  description = "Additional IAM policy attached to the task definition role"
  type        = string
  default     = ""
}

variable "managed_policies" {
  description = "IAM managed policies attached to the ECS task role"
  type        = list(string)
  default     = []
}

variable "deployment_maximum_percent" {
  description = "(Optional) The upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment. Not valid when using the DAEMON scheduling strategy."
  type        = number
  default     = 200
}

variable "deployment_minimum_healthy_percent" {
  description = "(Optional) The lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment."
  type        = number
  default     = 50
}

variable "health_check_grace_period_seconds" {
  description = "(Optional) Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 2147483647. Only valid for services configured to use load balancers."
  type        = number
  default     = 0
}

variable "force_new_deployment" {
  description = "Enable to force a new task deployment of the service."
  type        = bool
  default     = true
}

variable "container_port" {
  description = "The port on the container to associate with the load balancer."
  type        = number
}

variable "command" {
  default     = []
  description = "The command that is passed to the container"
  type        = list(string)
}

variable "dnsSearchDomains" {
  default     = []
  description = "A list of DNS search domains that are presented to the container"
  type        = list(string)
}

variable "dnsServers" {
  default     = []
  description = "A list of DNS servers that are presented to the container"
  type        = list(string)
}

variable "dockerLabels" {
  default     = {}
  description = "A key/value map of labels to add to the container"
  type        = map(string)
}

variable "dockerSecurityOptions" {
  default     = []
  description = "A list of strings to provide custom labels for SELinux and AppArmor multi-level security systems"
  type        = list(string)
}

variable "entryPoint" {
  default     = []
  description = "The entry point that is passed to the container"
  type        = list(string)
}

variable "environment" {
  type    = list(map(string))
  default = []
}

variable "extraHosts" {
  default     = []
  description = "A list of hostnames and IP address mappings to append to the /etc/hosts file on the container"
  type        = list(string)
}

variable "links" {
  default     = []
  description = "The link parameter allows containers to communicate with each other without the need for port mappings"
  type        = list(string)
}

variable "healthCheck" {
  default     = {}
  description = "The health check command and associated configuration parameters for the container"
  type        = any
}

variable "linuxParameters" {
  default     = {}
  description = "Linux-specific modifications that are applied to the container, such as Linux KernelCapabilities"
  type        = any
}

variable "log_group_name" {
  type        = string
  description = "The name of the ECS CloudWatch log group"
}

variable "mountPoints" {
  default     = []
  description = "The mount points for data volumes in your container"
  type        = list(any)
}

variable "repositoryCredentials" {
  default     = {}
  description = "The private repository authentication credentials to use"
  type        = map(string)
}

variable "resourceRequirements" {
  default     = []
  description = "The type and amount of a resource to assign to a container"
  type        = list(string)
}

variable "secrets" {
  default     = []
  description = "The secrets to pass to the container"
  type        = list(map(string))
}

variable "systemControls" {
  default     = []
  description = "A list of namespaced kernel parameters to set in the container"
  type        = list(string)
}

variable "ulimits" {
  default     = []
  description = "A list of ulimits to set in the container"
  type        = list(any)
}

variable "volumesFrom" {
  default     = []
  description = "Data volumes to mount from another container"
  type        = list(string)
}

variable "cpu" {
  default     = 0
  description = "The number of cpu units reserved for the container"
  type        = number
}

variable "disableNetworking" {
  type        = bool
  default     = false
  description = "When this parameter is true, networking is disabled within the container"
}

variable "essential" {
  type        = bool
  default     = true
  description = "If the essential parameter of a container is marked as true, and that container fails or stops for any reason, all other containers that are part of the task are stopped"
}

variable "hostname" {
  default     = ""
  description = "The hostname to use for your container"
}

variable "image_repo" {
  type        = string
  description = "The image repo used to start the container"
}

variable "image_tag" {
  type        = string
  description = "The image tag used to start the container"
}

variable "interactive" {
  type        = bool
  default     = false
  description = "When this parameter is true, this allows you to deploy containerized applications that require stdin or a tty to be allocated"
}

variable "memory" {
  default     = 512
  description = "The hard limit (in MiB) of memory to present to the container"
  type        = number
}

variable "container_memory_hard_limit" {
  description = "The amount (in MiB) of memory used by the task"
  type        = number
}

variable "container_memory_soft_limit" {
  description = "The soft limit (in MiB) of memory to reserve for the container. "
  type        = number
}

variable "privileged" {
  type        = bool
  default     = true
  description = "When this parameter is true, the container is given elevated privileges on the host container instance"
}

variable "pseudoTerminal" {
  type        = bool
  default     = false
  description = "When this parameter is true, a TTY is allocated"
}

variable "readonlyRootFilesystem" {
  type        = bool
  default     = false
  description = "When this parameter is true, the container is given read-only access to its root file system"
}

variable "user" {
  default     = ""
  description = "The user name to use inside the container"
}

variable "workingDirectory" {
  default     = ""
  description = "The working directory in which to run commands inside the container"
}

variable "execution_role_arn" {
  default     = ""
  description = "The Amazon Resource Name (ARN) of the task execution role that the Amazon ECS container agent and the Docker daemon can assume"
}

variable "ipc_mode" {
  default     = null
  description = "The IPC resource namespace to use for the containers in the task"
}

variable "network_mode" {
  default     = "bridge"
  description = "The Docker networking mode to use for the containers in the task"
}

variable "pid_mode" {
  default     = null
  description = "The process namespace to use for the containers in the task"
}

variable "placement_constraints" {
  default     = []
  description = "An array of placement constraint objects to use for the task"
  type        = list(string)
}

variable "requires_compatibilities" {
  default     = []
  description = "The launch type required by the task"
  type        = list(string)
}

variable "task_role_arn" {
  default     = ""
  description = "The short name or full Amazon Resource Name (ARN) of the IAM role that containers in this task can assume"
}

variable "volumes" {
  default     = []
  description = "A list of volume definitions in JSON format that containers in your task may use"
  type        = list(any)
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "target_group_arn" {
  description = "The ARN of the Load Balancer target group to associate with the service."
  type        = string
  default     = null
}

variable "ordered_placement_strategy" {
  description = "Service level strategy rules that are taken into consideration during task placement. List from top to bottom in order of precedence."
  type = list(object({
    type  = string
    field = string
  }))
  default = []
}

variable "min_capacity" {
  type        = number
  description = "The min capacity of the ECS service"
}

variable "max_capacity" {
  type        = number
  description = "The max capacity of the ECS service"
}

variable "target_value" {
  type        = number
  description = "The target value for the metric"
}

variable "scale_in_cooldown" {
  type        = number
  description = "The amount of time, in seconds, after a scale in activity completes before another scale in activity can start"
  default     = 120
}

variable "scale_out_cooldown" {
  type        = number
  description = "The amount of time, in seconds, after a scale out activity completes before another scale out activity can start"
  default     = 60
}

variable "predefined_metric_type" {
  type        = string
  description = "The metric type."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to resources"
}

variable "enable_execute_command" {
  type        = bool
  default     = false
  description = "Enable aws ecs execute_command"
}

variable "service_discovery_namespace_id" {
  type    = string
  default = null
}
