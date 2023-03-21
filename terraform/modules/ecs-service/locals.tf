locals {
  healthCheck = replace(jsonencode(var.healthCheck), local.classes["digit"], "$1")

  linuxParameters = replace(
    replace(
      replace(jsonencode(var.linuxParameters), "/\"1\"/", "true"),
      "/\"0\"/",
      "false",
    ),
    local.classes["digit"],
    "$1",
  )

  logConfiguration = jsonencode({
    "logDriver" : "awslogs",
    "options" : {
      "awslogs-group" : var.log_group_name,
      "awslogs-region" : data.aws_region.current.name,
      "awslogs-stream-prefix" : var.name
    }
  })

  mountPoints = replace(
    replace(jsonencode(var.mountPoints), "/\"1\"/", "true"),
    "/\"0\"/",
    "false",
  )

  portMappings = replace(jsonencode([
    {
      containerPort = var.container_port
    },
  ]), local.classes["digit"], "$1")

  ulimits = replace(jsonencode(var.ulimits), local.classes["digit"], "$1")

  volumesFrom = replace(
    replace(jsonencode(var.volumesFrom), "/\"1\"/", "true"),
    "/\"0\"/",
    "false",
  )

  classes = {
    digit = "/\"(-[[:digit:]]|[[:digit:]]+)\"/"
  }

  container_definitions = jsonencode([{
    command                = jsonencode(var.command) == "[]" ? "null" : var.command
    cpu                    = var.cpu == 0 ? "null" : var.cpu
    disableNetworking      = var.disableNetworking ? true : false
    dnsSearchDomains       = jsonencode(var.dnsSearchDomains) == "[]" ? "null" : var.dnsSearchDomains
    dnsServers             = jsonencode(var.dnsServers) == "[]" ? "null" : var.dnsServers
    dockerLabels           = jsonencode(var.dockerLabels) == "{}" ? "null" : var.dockerLabels
    dockerSecurityOptions  = jsonencode(var.dockerSecurityOptions) == "[]" ? "null" : var.dockerSecurityOptions
    entryPoint             = jsonencode(var.entryPoint) == "[]" ? "null" : var.entryPoint
    environment            = jsonencode(var.environment) == "[]" ? "null" : var.environment
    essential              = var.essential ? true : false
    extraHosts             = jsonencode(var.extraHosts) == "[]" ? "null" : var.extraHosts
    healthCheck            = local.healthCheck == "{}" ? "null" : jsondecode(local.healthCheck)
    hostname               = var.hostname == "" ? "null" : var.hostname
    image                  = "${var.image_repo}:${var.image_tag}"
    interactive            = var.interactive ? true : false
    links                  = jsonencode(var.links) == "[]" ? "null" : var.links
    linuxParameters        = local.linuxParameters == "{}" ? "null" : jsondecode(local.linuxParameters)
    logConfiguration       = local.logConfiguration == "{}" ? "null" : jsondecode(local.logConfiguration)
    memory                 = var.memory == 0 ? "null" : var.memory
    memoryReservation      = var.container_memory_soft_limit == 0 ? "null" : var.container_memory_soft_limit
    mountPoints            = local.mountPoints == "[]" ? "null" : jsondecode(local.mountPoints)
    name                   = var.name == "" ? "null" : var.name
    portMappings           = local.portMappings == "[]" ? "null" : jsondecode(local.portMappings)
    privileged             = var.privileged ? true : false
    pseudoTerminal         = var.pseudoTerminal ? true : false
    readonlyRootFilesystem = var.readonlyRootFilesystem ? true : false
    repositoryCredentials  = jsonencode(var.repositoryCredentials) == "{}" ? "null" : var.repositoryCredentials
    resourceRequirements   = jsonencode(var.resourceRequirements) == "[]" ? "null" : var.resourceRequirements
    secrets                = jsonencode(var.secrets) == "[]" ? "null" : var.secrets
    systemControls         = jsonencode(var.systemControls) == "[]" ? "null" : var.systemControls
    ulimits                = local.ulimits == "[]" ? "null" : jsondecode(local.ulimits)
    user                   = var.user == "" ? "null" : var.user
    volumesFrom            = local.volumesFrom == "[]" ? "null" : jsondecode(local.volumesFrom)
    workingDirectory       = var.workingDirectory == "" ? "null" : var.workingDirectory
  }])

}
