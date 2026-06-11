"""
resources.py â€“ Lista Azure resurse pomoÄ‡u Python SDK-a
Instaliraj: pip install azure-identity azure-mgmt-resource
"""

from azure.identity import DefaultAzureCredential
from azure.mgmt.resource import ResourceManagementClient
import os

RESOURCE_GROUP = "rg-algebra-project"
# Postavi svoju Subscription ID ili je uÄitaj iz env varijable
SUBSCRIPTION_ID = os.environ.get("AZURE_SUBSCRIPTION_ID", "f1b2cd54-bdee-46bb-8185-d0f4cc3cf10e")

credential = DefaultAzureCredential()
client = ResourceManagementClient(credential, SUBSCRIPTION_ID)

print(f"\n{'='*60}")
print(f"  Azure resursi u grupi: {RESOURCE_GROUP}")
print(f"{'='*60}\n")
print(f"{'Naziv':<45} {'Tip':<45} {'Lokacija'}")
print("-" * 110)

resources = list(client.resources.list_by_resource_group(RESOURCE_GROUP))
for r in sorted(resources, key=lambda x: x.type):
    print(f"{r.name:<45} {r.type:<45} {r.location}")

print(f"\nUkupno resursa: {len(resources)}")
