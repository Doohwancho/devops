output "vpc" {
  value = module.vpc #A
}

output "sg" {
  value = { #B
    lb     = module.lb_sg.security_group.id #B
    db     = module.db_sg.security_group.id #B
    websvr = module.websvr_sg.security_group.id #B
	elasticache = module.elasticache_sg.security_group.id #B
	prometheus = module.prometheus_sg.security_group.id
  }
}
