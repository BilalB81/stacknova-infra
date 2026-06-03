# stacknova-infra

Infrastructure as Code pour l'environnement de recette StackNova.
Provisionne via Terraform (provider Docker Kreuzwerker) et configure via Ansible (mode raw, sans Python sur la cible).

## Prerequis

| Outil | Version utilisee |
|---|---|
| Docker | 29.5.0 |
| Terraform | 1.6.6 |
| Ansible | 2.19.4 |
| Collection Ansible | community.docker |

Verification :
- `docker --version`
- `terraform version`
- `ansible --version`
- `ansible-galaxy collection install community.docker`

## Deploiement rapide

```bash
bash scripts/deploy.sh
```

Cette commande enchaine terraform init, terraform apply, puis le playbook Ansible.
Application accessible sur http://localhost:8080

## Destruction de l'environnement

```bash
cd terraform && terraform destroy
```

## Reproductibilite

Teste via le cycle destroy/redeploy :
1. `cd terraform && terraform destroy` - supprime le conteneur
2. `bash scripts/deploy.sh` - reprovisionne from scratch

Resultat identique grace a :
- Version Nginx epinglee (nginx:1.25.3)
- Version provider Terraform epinglee (~> 3.0.2)
- Horodatage genere dynamiquement par Ansible

## Questions theoriques

**Q1. Difference Terraform / Ansible**
Terraform est un outil de provisionnement declaratif : il cree et detruit des ressources (conteneurs, VMs). Ansible est un outil de gestion de configuration : il configure ce qui tourne deja. Dans ce projet, Terraform cree le conteneur Nginx, Ansible y depose la page HTML. Ils sont complementaires car ils adressent des couches differentes de l'infrastructure.

**Q2. Role du state file Terraform**
Le fichier terraform.tfstate est la memoire de Terraform : il mappe chaque ressource declaree a son equivalent reel. Sans lui, Terraform ne peut pas calculer les differences. En equipe, un state local non partage peut entrainer des destructions accidentelles ou des ressources orphelines. La bonne pratique est un backend distant (S3, Terraform Cloud) avec verrouillage.

**Q3. Idempotence**
Un outil idempotent produit le meme resultat qu'on l'execute une ou dix fois. Dans ce projet : relancer ansible-playbook reecrit la meme page HTML et ne retourne pas d'erreur si Nginx est deja actif. Terraform est aussi idempotent : un second apply sans changement de code ne modifie rien.

**Q4. terraform apply vs terraform apply -replace**
terraform apply applique uniquement les changements detectes par rapport au state. terraform apply -replace force la destruction et recreation d'une ressource specifique meme sans changement detecte. On l'utilise quand une ressource est corrompue ou dans un etat incoherent non visible dans le state (ex : conteneur plante).

**Q5. Pourquoi eviter le tag latest**
Le tag latest est un alias mobile qui pointe sur la derniere image publiee, changeant a chaque release. Deux deploiements identiques dans le temps peuvent embarquer des versions differentes de Nginx et introduire des regressions. Epingler une version (nginx:1.25.3) garantit la reproductibilite et la tracabilite.

## Arborescence

```
stacknova-infra/
├── terraform/
│   ├── providers.tf
│   ├── main.tf
│   └── outputs.tf
├── ansible/
│   ├── inventory.ini
│   └── playbook.yml
├── scripts/
│   └── deploy.sh
├── screens/
│   └── (captures d ecran)
└── README.md
```
