# TFE module registry proxy

This repo contains a PoC of module registry proxy implemented using AWS API Gateway. It's intended to sit in front of a Spacelift module registry, allowing you to use the Spacelift registry temporarily without having to update every `module` definition in Terraform that's pointing at an old registry.

The code for the proxy is defined in the `tfe-module-proxy` folder, and consists of the following components:

- An AWS [HTTP API Gateway](./tfe-module-proxy/apigw.tf).
- A [gateway route definition](./tfe-module-proxy/terraform-json.tf) and [Lambda](./tfe-module-proxy/terraform-json.mjs) for implementing the `.well-known/terraform.json` file.
- A [gateway route definition](./tfe-module-proxy/list-versions.tf) and [Lambda](./tfe-module-proxy/list-versions.mjs) for implementing the `.registry/modules/v1/{namespace}/{name}/{provider}/versions` endpoint.
- A [gateway route definition](./tfe-module-proxy/get-version-download-url.tf) and [Lambda](./tfe-module-proxy/get-version-download-url.mjs) for implementing the `registry/modules/v1/{namespace}/{name}/{provider}/{version}/download` endpoint.

To use the module, specify the URL of your Spacelift instance, along with the Spacelift account name (which must be all lowercase):

```terraform
module "tfe-module-proxy" {
  source = "./tfe-module-proxy"

  artifacts_path = "${path.root}/artifacts"

  # Update these two parameters to point at your correct Spacelift URL and account name
  spacelift_base_url     = "https://spacelift.myorg.com"
  spacelift_account_name = "admin"
}
```
