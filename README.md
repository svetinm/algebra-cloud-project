# Algebra Cloud Project – Svetin Matijaš

> Projektni zadatak iz kolegija *Administering Cloud Solutions*  
> Algebra Bernays University, 2025/2026

## Opis

Sigurna Azure infrastruktura za hosting multi-container aplikacije s potpuno privatnim pristupom, deployirana pomoću Terraforma.

## Arhitektura

- **AKS** – Kubernetes klaster za containeriziranu aplikaciju
- **Azure Function App** – Serverless PowerShell funkcija
- **Application Gateway** – Centralni ingress, HTTPS, path-based routing (`/aks`, `/functionap`)
- **PostgreSQL Flexible Server** – Privatna baza podataka
- **Azure Storage** – Blob container + File Share + File Sync
- **Azure Key Vault** – Lozinke i SSL certifikat
- **Azure Container Registry** – Private Docker registry
- **Jump VM** – Windows VM za administraciju
- **Log Analytics + Workbook** – Centralizirani monitoring

## Struktura repozitorija

```
├── terraform/          # Sva Terraform konfiguracija
├── aks-app/            # Demo aplikacija za AKS (Dockerfile + K8s YAML)
├── func-app/           # Azure Function App (PowerShell)
└── scripts/            # Pomoćne skripte (az cli + Python)
```

## Preduvjeti

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)

## Deployment

### 1. Postavi svoj javni IP

Pronađi svoj IP na https://ifconfig.me i zamijeni `1.2.3.4` u:
- `terraform/security.tf`
- `terraform/storage.tf`
- `terraform/function.tf`
- `terraform/jump.tf`

### 2. Inicijalizacija i deploy

```bash
az login
cd terraform
terraform init
terraform plan
terraform apply
```

### 3. Deploy aplikacija

```powershell
# AKS
cd aks-app
.\run.ps1

# Function App
cd func-app
.\deploy.ps1
```

## Tags

Svi resursi imaju tagove:
- `university: Algebra`
- `student: student@algebra.hr`
