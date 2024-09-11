output "vpc" {
  value = module.vpc 
}

output "sg" {
  value = { 
  db     = module.db_sg.security_group.id 
  websvr = module.websvr_sg.security_group.id 
	prometheus = module.prometheus_sg.security_group.id
  # lb     = module.lb_sg.security_group.id 
	# elasticache = module.elasticache_sg.security_group.id 
  # stress_test = module.stress_test_svr_sg.security_group.id
  }
}
