

locals {
    name = "${var.project_name}-${var.stage}"
    common_tags = {
        Project = var.project_name
        Environment = var.stage
    }
}

# create VPC and internet gteway

resource "aws_vpc" "main" {
   cidr_block= var.vpc_cidr
   enable_dns_hostnames = true
   enable_dns_support = true

   tags = merge(
    {
        Name = "${local.name}-vpc" ,
        
    },
    local.common_tags
   )
    
    #lifecycle {
     # prevent_destroy = var.stage == "prod"
    #}

   }


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${local.name}-igw"
  }
}



# create availability zones

data "aws_availability_zones" "available" {
  state = "available"
}


#creating subnets

resource "aws_subnet" "public" {
  count= var.az_count
  vpc_id = aws_vpc.main.id
  cidr_block= cidrsubnet(var.vpc_cidr,9,count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.name}-public-subnet-${count.index}"
  }
}

resource "aws_subnet" "private" {
  count= var.az_count
  vpc_id  = aws_vpc.main.id
  cidr_block= cidrsubnet(var.vpc_cidr, 8, count.index + var.az_count) #here im creating private subnets by adding the number of availability zones to the count index, so that the private subnets will have different CIDR blocks than the public subnets
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${local.name}-private-subnet-${count.index + 1}"
  }
}


#creating nat and elastic ip for nat 
resource "aws_eip" "nat" {
  count= var.az_count
  domain = "vpc" #important to give this value to create an elastic ip for nat gateway

  tags = {
    Name = "${local.name}-nat-eip-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "main" {
  count= var.single_nat_gateway ? 1 : var.az_count #one nat either shared or individual for each az
  allocation_id = aws_eip.nat[count.index].id
  subnet_id= aws_subnet.public[count.index].id

  tags = merge(
    { Name = "${local.name}-nat-${count.index + 1}" },
    local.common_tags
  )

  depends_on = [aws_internet_gateway.igw]
}

#creating route tables and routes

resource "aws_route_table" "public" {
    vpc_id=aws_vpc.main.id


    route {
        cidr_block = "0.0.0.0/0" #source of traffic is anything coming from public subnet directing to internet gateway 
        gateway_id = aws_internet_gateway.igw.id
    }

    tags ={
        Name ="${local.name}-public-route-table"
    }
  
}


resource "aws_route_table" "private" {
  count = var.az_count
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id= var.single_nat_gateway ? aws_nat_gateway.main[0].id : aws_nat_gateway.main[count.index].id #if single nat gateway is true then use the first nat gateway else use the nat gateway for each az
  }

    tags = merge(
        {
        Name = "${local.name}-private-route-table-${count.index + 1}"
    },
        local.common_tags
    )
}


resource "aws_route_table_association" "public" {
  count= var.az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}


#creating flow logs for vpc only if the stage is prod
    resource "aws_iam_role" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name = "${var.project_name}-${var.stage}-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "flow_logs" {
  count      = var.enable_flow_logs ? 1 : 0
  role       = aws_iam_role.flow_logs[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_cloudwatch_log_group" "flow_log" {
  count             = var.enable_flow_logs ? 1 : 0
  name              = "/aws/vpc/flowlogs/${local.name}"
  retention_in_days = 7
  tags              = local.common_tags
}

resource "aws_flow_log" "main" {
  count                = var.enable_flow_logs ? 1 : 0
  log_destination      = aws_cloudwatch_log_group.flow_log[0].arn
  log_destination_type = "cloud-watch-logs"
  iam_role_arn         = aws_iam_role.flow_logs[0].arn
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id

  tags = merge(
    { Name = "${local.name}-vpc-flow-log" },
    local.common_tags
  )
}
  