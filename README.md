# YnovCloudModule2026

Un projet Terraform complet de progression pédagogique montrant la gestion d'infrastructure Azure, du déploiement simple en fichier unique aux patterns avancés modulaires multi-environnements.

---

## 📋 Vue d'ensemble

Ce projet contient 4 exercices progressifs qui mettent en avant les bonnes pratiques Terraform :

| Exercice | Complexité | Accent | Concepts clés |
|----------|-----------|--------|---------------|
| **Ex1** | ⭐ Basique | Infrastructure monofile | Provider, ressources, backend distant |
| **Ex2** | ⭐⭐ Débutant | Introduction aux modules | Composition, outputs |
| **Ex3** | ⭐⭐⭐ Intermédiaire | Multi-environnement | GitHub Actions, tfvars, backend par environnement |
| **Ex4** | ⭐⭐⭐⭐ Avancé | Infrastructure factory multi-env | JSON-driven, environnements Dev/Prod, scalabilité |

---

## 🎯 Détail des exercices

### **Ex1 : Terraform basique - Déploiement monofile**

**Emplacement :** `Exercices/Terraform/Ex1/`

**Objectif :** Apprendre les concepts fondamentaux de Terraform en créant une VM Azure Linux simple avec réseau dans un seul fichier `main.tf`.

**Architecture :**
```
Groupe de ressources existant (RG-B3-Eric)
├── Réseau virtuel (VNET-TF: 10.0.0.0/16)
│   └── Sous-réseau (SUBNET-APP: 10.0.1.0/24)
├── Interface réseau (NIC)
├── Adresse IP publique
└── Machine virtuelle Linux (Standard_D2als_v6)
```

**Concepts clés :**
- Configuration du provider (`azurerm`)
- Utilisation d'un Resource Group existant via source de données (`data.azurerm_resource_group`)
- Création de ressources et dépendances
- Configuration du backend (état distant Azure Storage)
- Authentification VM par mot de passe (`admin_password`)
- Références et interpolation de ressources

**Ressources créées :**
- 1 Groupe de ressources référencé (existant)
- 1 Réseau virtuel
- 1 Sous-réseau
- 1 Interface réseau
- 1 Adresse IP publique
- 1 VM Linux

**Exécution :**
```bash
cd Exercices/Terraform/Ex1/
terraform init
terraform plan -var="vm_admin_password=<mot_de_passe>"
terraform apply -var="vm_admin_password=<mot_de_passe>"
```

**Résultat attendu :** Une VM Linux basique créée dans le Resource Group existant, accessible sur son IP publique avec l'utilisateur/mot de passe configurés.

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
- Utilisation d'un Resource Group existant via `data.azurerm_resource_group`
- Encapsulation des modules

**Variables utilisées :**
- `location` (avec défaut)
- `rg_name` (avec défaut)
- `vm_name` (avec défaut)
- `admin_username` (avec défaut)
- `admin_password` (sensible, fourni via `terraform.tfvars`)
- `vnet_params` (objet complexe)

**Exécution :**
```bash
cd Exercices/Terraform/Ex2/
terraform init
terraform plan  --var-file=terraform.tfvars
terraform apply --var-file=terraform.tfvars
```

**Résultat attendu :** Même résultat fonctionnel qu'Ex1 (VNet + VM Linux + IP publique), mais déployé avec architecture modulaire et sortie d'IP via output racine.

---

### **Ex3 : Multi-environnement - GitHub Workflow & Tfvars**

**Emplacement :** `Exercices/Terraform/Ex3/`

**Objectif :** Apprendre à gérer plusieurs environnements (Dev, Prod) avec un déploiement piloté par GitHub Actions, en utilisant des fichiers `.tfvars` spécifiques et une clé de backend dédiée par environnement.

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
- Déclenchement manuel du workflow GitHub (`workflow_dispatch`)
- Sélection de l'environnement (`dev` ou `prod`) via input du workflow
- Fichiers tfvars spécifiques par environnement
- Backend state séparé par clé (`dev.terraform.tfstate` / `prod.terraform.tfstate`)
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

**Exécution (via GitHub Workflow) :**
```bash
# Workflow principal
.github/workflows/terraform-ex3-deploy.yml

# Action composite utilisée
Exercices/Terraform/Ex3/.github/actions/terraform/action.yml

# Paramètres du workflow
environment: dev|prod
operation: apply
```

Depuis GitHub, lancer le workflow `Terraform Ex3 Deploy` puis choisir l'environnement (`dev` ou `prod`).

**Lancer le workflow dans GitHub (pas-à-pas) :**
1. Ouvrir le dépôt GitHub.
2. Aller dans l'onglet **Actions**.
3. Sélectionner le workflow **Terraform Ex3 Deploy**.
4. Cliquer sur **Run workflow**.
5. Choisir l'input `environment` (`dev` ou `prod`).
6. Lancer l'exécution et suivre les logs du job **Terraform Deploy**.

**Conventions de nommage (Ex3) :**
- Valeurs autorisées pour `environment` : `dev` et `prod` uniquement.
- Utiliser des valeurs en minuscules, sans espaces.
- Garder l'alignement entre les trois éléments :
  - input workflow : `environment`
  - fichier variables : `<environment>.tfvars`
  - état Terraform : `<environment>.terraform.tfstate`
- Exemples valides : `dev`, `prod`.
- Exemples invalides : `Dev`, `production`, `pre-prod`.

**Récapitulatif rapide (Dev vs Prod) :**

| Cible | Input `environment` | Fichier variables | Clé backend state | GitHub Environment |
|-------|----------------------|-------------------|-------------------|--------------------|
| Dev   | `dev`               | `dev.tfvars`      | `dev.terraform.tfstate` | `dev` |
| Prod  | `prod`              | `prod.tfvars`     | `prod.terraform.tfstate` | `prod` |

**Checklist avant Run workflow (Ex3) :**
- Les secrets GitHub sont définis : `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`.
- La branche cible est `main` (l'étape apply est conditionnée à `refs/heads/main`).
- Les fichiers `dev.tfvars` et `prod.tfvars` existent dans `Exercices/Terraform/Ex3/`.
- Le backend Azure Storage existe et est accessible (Resource Group, Storage Account, Container).
- La valeur `environment` choisie correspond bien à l'environnement GitHub (`dev` ou `prod`).

Le workflow exécute automatiquement :
1. `terraform init -backend-config="key=<environment>.terraform.tfstate"`
2. `terraform plan -var-file=<environment>.tfvars`
3. `terraform apply -var-file=<environment>.tfvars -auto-approve`

**Résultat attendu :** Infrastructure Azure séparée pour Dev et Prod avec états Terraform distincts et pipeline reproductible.

---

### **Ex4 : Avancé - Pattern Infrastructure Factory Multi-environnements**

**Emplacement :** `Exercices/Terraform/Ex4/`

**Objectif :** Apprendre les patterns avancés : infrastructure pilotée par JSON, dépendances complexes entre modules, génération de ressources dynamiques et gestion d'infrastructure multi-environnements (Dev/Prod) avec un seul fichier `infra.json`.

**Architecture :**
```
Infrastructure Factory (pilotée par JSON)
├── Environnement dev
│   ├── rg-data-dev
│   └── rg-web-dev
├── Environnement prod
│   ├── rg-data-prod
│   └── rg-web-prod
└── Modules partagés
  ├── network
  ├── private_dns
  ├── sql
  ├── storage
  ├── keyvault
  └── webapp
```

**Structure des répertoires :**
```
Ex4/
├── main.tf                          # Orchestration factory
├── infra.json                       # Définition multi-environnements
├── modules/
│   ├── network/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── private_dns/
│   │   ├── main.tf
│   │   └── variables.tf
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
└── infra.json                       # FICHIER DE CONFIGURATION (DEV + PROD)
```

**Concepts clés :**
- Parsing JSON avec `jsondecode()`
- Génération de ressources dynamiques avec `for_each` + `flatten()`
- Dépendances complexes entre modules
- Sélection d'environnement via `terraform workspace` ou variable `environment`
- Points de terminaison privés pour la sécurité
- Zones DNS privées associées aux Private Endpoints (SQL, Storage, Key Vault, Web App + SCM)
- Liaison automatique des zones DNS privées au VNet de chaque Resource Group
- Délégation de sous-réseaux pour intégration VNet
- Infrastructure multi-niveaux en code

**Définition Infrastructure (infra.json) :**
```json
{
  "environments": {
    "dev": {
      "project_name": "factory-lab-2026-dev",
      "location": "francecentral",
      "resource_groups": {
        "rg-data-dev": {
          "networking": {...},
          "private_dns": {
            "zones": [
              "privatelink.database.windows.net",
              "privatelink.blob.core.windows.net",
              "privatelink.vaultcore.azure.net"
            ]
          },
          "keyvault": {...},
          "storage_accounts": [...],
          "databases": [...]
        },
        "rg-web-dev": {
          "networking": {...},
          "private_dns": {
            "zones": [
              "privatelink.azurewebsites.net",
              "privatelink.scm.azurewebsites.net"
            ]
          },
          "webapp": {...}
        }
      }
    },
    "prod": {
      "project_name": "factory-lab-2026-prod",
      "location": "francecentral",
      "resource_groups": {
        "rg-data-prod": {
          "networking": {...},
          "private_dns": {
            "zones": [
              "privatelink.database.windows.net",
              "privatelink.blob.core.windows.net",
              "privatelink.vaultcore.azure.net"
            ]
          },
          "keyvault": {...},
          "storage_accounts": [...],
          "databases": [...]
        },
        "rg-web-prod": {
          "networking": {...},
          "private_dns": {
            "zones": [
              "privatelink.azurewebsites.net",
              "privatelink.scm.azurewebsites.net"
            ]
          },
          "webapp": {...}
        }
      }
    }
  }
}
```

**Ajouter un 3e environnement (ex: `staging`) :**
1. Ajouter `environments.staging` dans `infra.json` en reprenant la même structure que `dev`/`prod`.
2. Utiliser des noms globaux Azure uniques (Storage Account, Key Vault, Web App).
3. Prévoir des plages CIDR non chevauchantes avec les autres environnements.

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

# Option 1: pilotage par workspace
terraform workspace new dev
terraform workspace select dev
terraform plan
terraform apply

terraform workspace new prod
terraform workspace select prod
terraform plan
terraform apply

# Option 2: sélection explicite
terraform plan -var="environment=dev"
terraform apply -var="environment=prod"
```

**Résultat attendu :** Infrastructure Azure complète pour l'environnement sélectionné avec :
- 2 Groupes de ressources
- 2 Réseaux virtuels avec 4 sous-réseaux
- Zones DNS privées créées et liées aux VNets (data/web)
- 1 Serveur SQL avec base de données et point de terminaison privé
- 2 Comptes de stockage avec points de terminaison privés
- 1 Key Vault avec point de terminaison privé
- 1 Web App avec point de terminaison privé, intégration VNet et zone DNS SCM privée

---

## 🔧 Commandes courantes

> Note : pour l'Ex3, le mode recommandé est le workflow GitHub (`.github/workflows/terraform-ex3-deploy.yml`) plutôt qu'une exécution locale directe.

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
terraform plan -var="environment=dev"
terraform plan -out=tfplan
```

### Appliquer la configuration
```bash
terraform apply
terraform apply tfplan
terraform apply -var-file=prod.tfvars
terraform apply -var="environment=prod"
```

### Afficher l'état
```bash
terraform show
terraform state list
terraform state show azurerm_resource_group.rg
```

### Gérer les Workspaces (Ex4)
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
- **Mot de passe administrateur VM** pour Ex1/Ex2/Ex3 (variables `vm_admin_password` ou `admin_password` selon l'exercice)

---

## 🔐 Configuration du Backend

Chaque exercice utilise Azure Storage pour l'état distant :

```bash
# Ex1-Ex4: Remplacer [VOS_INITIALES]
storage_account_name = "sttfstate[VOS_INITIALES]"
```

Initialiser le backend :
```bash
terraform init -backend-config="key=exercise.tfstate"
```

## 🛠️ Dépannage

### Mot de passe VM manquant
Fournir la variable sensible au plan/apply :
```bash
terraform plan -var="vm_admin_password=<mot_de_passe>"
terraform apply -var="vm_admin_password=<mot_de_passe>"
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
