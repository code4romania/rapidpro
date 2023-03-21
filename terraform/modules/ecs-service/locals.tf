locals {
  command               = jsonencode(var.command)
  dnsSearchDomains      = jsonencode(var.dnsSearchDomains)
  dnsServers            = jsonencode(var.dnsServers)
  dockerLabels          = jsonencode(var.dockerLabels)
  dockerSecurityOptions = jsonencode(var.dockerSecurityOptions)
  entryPoint            = jsonencode(var.entryPoint)
  environment           = jsonencode(var.environment)
  extraHosts            = jsonencode(var.extraHosts)
  links                 = jsonencode(var.links)
  healthCheck           = replace(jsonencode(var.healthCheck), local.classes["digit"], "$1")

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


  repositoryCredentials = jsonencode(var.repositoryCredentials)
  resourceRequirements  = jsonencode(var.resourceRequirements)
  secrets               = jsonencode(var.secrets)
  systemControls        = jsonencode(var.systemControls)

  ulimits = replace(jsonencode(var.ulimits), local.classes["digit"], "$1")

  volumesFrom = replace(
    replace(jsonencode(var.volumesFrom), "/\"1\"/", "true"),
    "/\"0\"/",
    "false",
  )

  classes = {
    digit = "/\"(-[[:digit:]]|[[:digit:]]+)\"/"
  }

  container_definitions = format("[%s]", {
    command                = local.command == "[]" ? "null" : local.command
    cpu                    = var.cpu == 0 ? "null" : var.cpu
    disableNetworking      = var.disableNetworking ? true : false
    dnsSearchDomains       = local.dnsSearchDomains == "[]" ? "null" : local.dnsSearchDomains
    dnsServers             = local.dnsServers == "[]" ? "null" : local.dnsServers
    dockerLabels           = local.dockerLabels == "{}" ? "null" : local.dockerLabels
    dockerSecurityOptions  = local.dockerSecurityOptions == "[]" ? "null" : local.dockerSecurityOptions
    entryPoint             = local.entryPoint == "[]" ? "null" : local.entryPoint
    environment            = local.environment == "[]" ? "null" : local.environment
    essential              = var.essential ? true : false
    extraHosts             = local.extraHosts == "[]" ? "null" : local.extraHosts
    healthCheck            = local.healthCheck == "{}" ? "null" : local.healthCheck
    hostname               = var.hostname == "" ? "null" : var.hostname
    image                  = "${var.image_repo}:${var.image_tag}"
    interactive            = var.interactive ? true : false
    links                  = local.links == "[]" ? "null" : local.links
    linuxParameters        = local.linuxParameters == "{}" ? "null" : local.linuxParameters
    logConfiguration       = local.logConfiguration == "{}" ? "null" : local.logConfiguration
    memory                 = var.memory == 0 ? "null" : var.memory
    memoryReservation      = var.container_memory_soft_limit == 0 ? "null" : var.container_memory_soft_limit
    mountPoints            = local.mountPoints == "[]" ? "null" : local.mountPoints
    name                   = var.name == "" ? "null" : var.name
    portMappings           = local.portMappings == "[]" ? "null" : local.portMappings
    privileged             = var.privileged ? true : false
    pseudoTerminal         = var.pseudoTerminal ? true : false
    readonlyRootFilesystem = var.readonlyRootFilesystem ? true : false
    repositoryCredentials  = local.repositoryCredentials == "{}" ? "null" : local.repositoryCredentials
    resourceRequirements   = local.resourceRequirements == "[]" ? "null" : local.resourceRequirements
    secrets                = local.secrets == "[]" ? "null" : local.secrets
    systemControls         = local.systemControls == "[]" ? "null" : local.systemControls
    ulimits                = local.ulimits == "[]" ? "null" : local.ulimits
    user                   = var.user == "" ? "null" : var.user
    volumesFrom            = local.volumesFrom == "[]" ? "null" : local.volumesFrom
    workingDirectory       = var.workingDirectory == "" ? "null" : var.workingDirectory
  })

}
