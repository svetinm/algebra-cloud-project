resource "azurerm_key_vault_certificate" "kv_cert" {
  name         = "appgw-cert"
  key_vault_id = azurerm_key_vault.kv.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      subject            = "CN=algebra-appgw.local, O=Algebra"
      validity_in_months = 12

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyEncipherment",
        "nonRepudiation",
      ]
    }
  }

  tags = local.tags
}
