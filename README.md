# TFE module registry proxy

This repo contains a PoC of module registry proxy implemented using AWS API Gateway. It's intended to sit in front of a Spacelift module registry, allowing you to temporarily continue using an existing registry without having to update every `module` definition in Terraform.

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

## Custom Hostname

The module doesn't include a custom hostname for the API gateway currently. Before you can use it you'll need to modify this PoC to setup an ACM certificate as well as a custom domain name (<https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_domain_name>).

## Spacelift stack registry credentials

In order for a Spacelift stack to be able to use the registry via the proxy, you need to configure your terraformrc file to include an entry for your old registry URL using the Spacelift token. You can do this using a Spacelift context containing the following mounted file called `add-old-registry-credentials.sh` (make sure to replace `<your-old-registry-url>` with the hostname of your previous registry):

```shell
#!/bin/sh

cat <<EOT >> ~/.terraformrc
credentials "<your-old-registry-url>" {
  token = "$SPACELIFT_API_TOKEN"
}
EOT

```

As well as the following _Before Init_ hook:

```shell
chmod u+x /mnt/workspace/add-old-registry-credentials.sh && /mnt/workspace/add-old-registry-credentials.sh
```

The advantage of doing this via a Spacelift context is that you can define this configuration in one place, and use it in all the affected stacks. You can also make use of [auto-attach rules](https://docs.spacelift.io/concepts/configuration/context#auto-attachments) to automatically attach the context to all the stacks that need to use the old registry.
