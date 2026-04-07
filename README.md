# YnovCloudModule2026

Un projet Terraform complet de progression pédagogique montrant la gestion d'infrastructure Azure, du déploiement simple en fichier unique aux patterns avancés modulaires multi-environnements.

---

## 📋 Vue d'ensemble

Ce projet contient 4 exercices progressifs qui mettent en avant les bonnes pratiques Terraform :

| Exercice | Complexité | Accent | Concepts clés |
|----------|-----------|--------|---------------|
| **Ex1** | ⭐ Basique | Infrastructure monofile | Provider, ressources, clés SSH |
| **Ex2** | ⭐⭐ Débutant | Introduction aux modules | Composition, outputs |
| **Ex3** | ⭐⭐⭐ Intermédiaire | Multi-environnement | Workspaces, tfvars, paramétrisation |
| **Ex4** | ⭐⭐⭐⭐ Avancé | Infrastructure factory | JSON-driven, modules complexes, scalabilité |

---

## 🎯 Détail des exercices

### **Ex1 : Terraform basique - Déploiement monofile**

**Emplacement :** `Exercices/Terraform/Ex1/`

**Objectif :** Apprendre les concepts fondamentaux de Terraform en créant une VM Azure Linux simple avec réseau dans un seul fichier `main.tf`.

**Architecture :**
```
Groupe de ressources
├── Réseau virtuel (VNET-TF: 10.0.0.0/16)
│   └── Sous-réseau (interne: 10.0.1.0/24)
├── Interface réseau (NIC)
├── Adresse IP publique
└── Machine virtuelle Linux (Standard_B1s)
```

**Concepts clés :**
- Configuration du provider (`azurerm`)
- Création de ressources et dépendances
- Configuration du backend (état distant Azure Storage)
- Authentification par clé SSH
- Références et interpolation de ressources

**Ressources créées :**
- 1 Groupe de ressources
- 1 Réseau virtuel
- 1 Sous-réseau
- 1 Interface réseau
- 1 Adresse IP publique
- 1 VM Linux

**Exécution :**
```bash
cd Exercices/Terraform/Ex1/
terraform init
terraform plan
terraform apply
```

**Résultat attendu :** Une VM Linux basique accessible en SSH à l'adresse IP publique.

---

### **Ex2 : Introduction aux modules - Séparation des responsabilités**

**Emplacement :** `Exercices/Terraform/Ex2/`

**Objectif :** Introduire l'architecture modulaire en séparant l'infrastructure en modules réutilisables `network` et `compute`. Apprendre à passer des valeurs entre modules via variables et outputs.

**Architecture :**
```
Module racine (main.tf)
├── Module Réseau
│   ├── Réseau virtuel
│   └── Sous-réseau (outputs: subnet_id)
└── Module Calcul
    ├── Interface réseau (utilise subnet_id)
    ├── Adresse IP publique
    └── Machine virtuelle Linux
```

**Structure des répertoires :**
```
Ex2/
├── main.tf                              # Configuration racine
├── variables.tf                         # Variables d'entrée
├── outputs.tf                           # Outputs du module
├── terraform.tfvars                    # Valeurs par défaut
└── modules/
    ├── network/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── compute/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

**Concepts clés :**
- Sourçage de modules (`source = "./modules/..."`)
- Entrées et sorties des modules
- Dépendances inter-modules
- Validation de variables
- Encapsulation des modules

**Variables utilisées :**
- `location` (avec défaut)
- `rg_name` (avec défaut)
- `vm_name` (avec défaut)
- `admin_username` (avec défaut)
- `vnet_params` (objet complexe)

**Exécution :**
```bash
cd Exercices/Terraform/Ex2/
terraform init
terraform plan
terraform apply -var-file=terraform.tfvars
```

**Résultat attendu :** Même résultat qu'Ex1 mais déployé avec architecture modulaire. Plus facile à réutiliser et maintenir.

---

### **Ex3 : Multi-environnement - Workspaces & Tfvars**

**Emplacement :** `Exercices/Terraform/Ex3/`

**Objectif :** Apprendre à gérer plusieurs environnements (Dev, Prod) en utilisant les workspaces Terraform et les fichiers `.tfvars` spécifiques à chaque environnement.

**Architecture :**
```
Configuration racine
├── Environnement Dev (dev.tfvars)
│   ├── RG: rg-app-dev
│   ├── VNet: vnet-dev (10.0.0.0/16)
│   └── VM: vm-dev-01
└── Environnement Prod (prod.tfvars)
    ├── RG: rg-app-prod
    ├── VNet: vnet-prod (172.16.0.0/16)
    └── VM: vm-prod-final
```

**Structure des répertoires :**
```
Ex3/
├── main.tf                          # Configuration racine + appels modules
├── variables.tf                     # Variables paramétrées
├── outputs.tf                       # Outputs du module
├── terraform.tfvars                # Valeurs par défaut
├── dev.tfvars                       # Spécificités environnement Dev
├── prod.tfvars                      # Spécificités environnement Prod
└── modules/
    ├── network/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── compute/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

**Concepts clés :**
- Workspaces Terraform (`terraform workspace new dev|prod`)
- Fichiers tfvars spécifiques par environnement
- Configuration backend avec séparation des workspaces
- Paramétrisation de la racine vers les modules
- Agrégation des outputs

**Exemple de Tfvars multiples :**
```hcl
# dev.tfvars
location       = "France Central"
rg_name        = "RG-APP-DEV"
admin_username = "admin-dev"

# prod.tfvars
location       = "North Europe"
rg_name        = "RG-APP-PROD"
admin_username = "admin-prod"
```

**Exécution :**
```bash
cd Exercices/Terraform/Ex3/

# Environnement Dev
terraform workspace new dev
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars

# Environnement Prod
terraform workspace new prod
terraform plan -var-file=prod.tfvars
terraform apply -var-file=prod.tfvars

# Basculer entre environnements
terraform workspace select dev
terraform workspace select prod
```

**Résultat attendu :** Infrastructure Azure séparée pour Dev et Prod avec fichiers d'état et configurations indépendantes.

---

### **Ex4 : Avancé - Pattern Infrastructure Factory**

**Emplacement :** `Exercices/Terraform/Ex4/`

**Objectif :** Apprendre les patterns avancés : infrastructure pilotée par JSON, dépendances complexes entre modules, génération de ressources dynamiques et gestion d'infrastructure à l'échelle.

**Architecture :**
```
Infrastructure Factory (pilotée par JSON)
├── Groupe de ressources 1: rg-data-prod
│   ├── Module Réseau
│   │   ├── VNet (10.0.0.0/16)
│   │   ├── Sous-réseau PE (10.0.1.0/24)
│   │   └── Sous-réseau Intégration (10.0.2.0/24)
│   ├── Module SQL
│   │   ├── Serveur MSSQL
│   │   ├── Base de données
│   │   └── Point de terminaison privé
│   ├── Module Stockage (2 comptes)
│   │   ├── Compte stockage 1 (LRS)
│   │   ├── Compte stockage 2 (GRS)
│   │   └── Points de terminaison privés
│   └── Module Key Vault
│       ├── Key Vault
│       └── Point de terminaison privé
└── Groupe de ressources 2: rg-web-prod
    ├── Module Réseau
    │   ├── VNet (10.1.0.0/16)
    │   ├── Sous-réseau PE
    │   └── Sous-réseau Intégration
    └── Module Web App
        ├── Plan App Service
        ├── Web App Linux
        └── Point de terminaison privé
```

**Structure des répertoires :**
```
Ex4/
├── main.tf                          # Orchestration factory
├── infra.json                       # Définition infrastructure
├── modules/
│   ├── network/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── compute/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── sql/
│   │   ├── main.tf
│   │   └── variables.tf
│   ├── storage/
│   │   ├── main.tf
│   │   └── variables.tf
│   ├── keyvault/
│   │   ├── main.tf
│   │   └── variables.tf
│   └── webapp/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── infra.json                       # FICHIER DE CONFIGURATION
```

**Concepts clés :**
- Parsing JSON avec `jsondecode()`
- Génération de ressources dynamiques avec `for_each` + `flatten()`
- Dépendances complexes entre modules
- Points de terminaison privés pour la sécurité
- Délégation de sous-réseaux pour intégration VNet
- Infrastructure multi-niveaux en code

**Définition Infrastructure (infra.json) :**
```json
{
  "project_name": "factory-lab-2026",
  "location": "francecentral",
  "resource_groups": {
    "rg-data-prod": {
      "location": "francecentral",
      "networking": {...},
      "keyvault": {...},
      "storage_accounts": [...],
      "databases": [...]
    },
    "rg-web-prod": {
      "location": "francecentral",
      "networking": {...},
      "webapp": {...}
    }
  }
}
```

**Patterns avancés utilisés :**
```hcl
# Aplatissement pour générer plusieurs ressources par GR
all_dbs = flatten([
  for rg, v in local.infra.resource_groups : [
    for d in lookup(v, "databases", []) : 
    merge(d, { rg = rg })
  ]
])

# Utilisation des données aplaties avec for_each
module "databases" {
  for_each = { for db in local.all_dbs : db.name => db }
  ...
}
```

**Exécution :**
```bash
cd Exercices/Terraform/Ex4/
terraform init
terraform plan
terraform apply
```

**Résultat attendu :** Infrastructure Azure complète avec :
- 2 Groupes de ressources
- 2 Réseaux virtuels avec 4 sous-réseaux
- 1 Serveur SQL avec base de données et point de terminaison privé
- 2 Comptes de stockage avec points de terminaison privés
- 1 Key Vault avec point de terminaison privé
- 1 Web App avec point de terminaison privé et intégration

---

## 🔧 Commandes courantes

### Initialiser Terraform
```bash
terraform init
```

### Valider la configuration
```bash
terraform validate
```

### Planifier le déploiement
```bash
terraform plan
terraform plan -var-file=dev.tfvars
terraform plan -out=tfplan
```

### Appliquer la configuration
```bash
terraform apply
terraform apply tfplan
terraform apply -var-file=prod.tfvars
```

### Afficher l'état
```bash
terraform show
terraform state list
terraform state show azurerm_resource_group.rg
```

### Gérer les Workspaces (Ex3)
```bash
terraform workspace list
terraform workspace new dev
terraform workspace select prod
terraform workspace delete dev
```

### Détruire l'infrastructure
```bash
terraform destroy
terraform destroy -var-file=dev.tfvars
```

---

## 📌 Prérequis

- **Abonnement Azure** avec permissions appropriées
- **Terraform** v1.0+
- **Azure CLI** (`az login`)
- **Paire de clés SSH** (pour Ex1-Ex3) : `ssh-keygen -t rsa -b 4096`

---

## 🔐 Configuration du Backend

Chaque exercice utilise Azure Storage pour l'état distant :

```bash
# Ex1-Ex3: Remplacer [VOS_INITIALES]
storage_account_name = "sttfstate[VOS_INITIALES]"

# Ex4: Utilise le backend local par défaut
```

Initialiser le backend :
```bash
terraform init -backend-config="key=exercise.tfstate"
```

## 🛠️ Dépannage

### Clé SSH non trouvée
Créer les clés SSH :
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
```

### Compte de stockage backend manquant
Remplacer le placeholder par le nom de compte de stockage réel et s'assurer que le compte existe dans Azure.

### Module non trouvé
Assurer que vous êtes dans le bon répertoire et exécuter `terraform init` avant `terraform plan`.

### Accès refusé
S'authentifier auprès d'Azure :
```bash
az login
```

---

## 📝 Notes

- Chaque exercice peut s'exécuter indépendamment
- Les fichiers d'état sont séparés par exercice
- Détruire les ressources quand elles ne sont pas utilisées pour éviter les frais Azure
- Toujours exécuter `terraform plan` avant `terraform apply`
- Utiliser les fichiers `.tfvars` pour les données sensibles (mais les exclure du contrôle de version)
