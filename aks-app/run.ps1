# run.ps1 – Build Docker image, push to ACR, deploy to AKS
# VAŽNO: Zamijeni naziv resource grupe ako si promijenio u provider.tf

$ResourceGroup = "rg-algebra-project"
$AcrName       = "acralgebrasmproject"
$AksName       = "aks-algebra-project"
$ImageName     = "demo-app"
$ImageTag      = "latest"

Write-Host "=== Dohvaćam AKS credentials ===" -ForegroundColor Cyan
az aks get-credentials --resource-group $ResourceGroup --name $AksName --overwrite-existing

Write-Host "=== Login na ACR ===" -ForegroundColor Cyan
az acr login --name $AcrName

Write-Host "=== Build Docker image ===" -ForegroundColor Cyan
docker build -t "${AcrName}.azurecr.io/${ImageName}:${ImageTag}" .

Write-Host "=== Push image na ACR ===" -ForegroundColor Cyan
docker push "${AcrName}.azurecr.io/${ImageName}:${ImageTag}"

Write-Host "=== Deploy na AKS ===" -ForegroundColor Cyan
kubectl apply -f app-aks.yaml

Write-Host "=== Status podova ===" -ForegroundColor Cyan
kubectl get pods
kubectl get svc

Write-Host "=== Gotovo! ===" -ForegroundColor Green
