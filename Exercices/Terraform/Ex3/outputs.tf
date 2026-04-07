output "ip_de_mon_serveur" {
  description = "IP finale affichée après le déploiement"
  # syntaxe : module.<NOM_DU_MODULE>.<NOM_DE_L_OUTPUT_DANS_LE_MODULE>
  value       = module.mon_compute.vm_public_ip
}