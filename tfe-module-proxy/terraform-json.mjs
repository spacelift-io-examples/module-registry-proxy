// TODO: allow the Spacelift URL to be passed via an input parameter
// TODO: remove logging of event data

export const handler = async (event) => {
  console.log("Received request for well-known/terraform.json");

  var response = {
    statusCode: 200,
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      "login.v1": {
        authz: "/terraform-login",
        client: "terraform-cli",
        grant_types: ["authz_code"],
        token: "https://spacelift.sh/terraform/token",
      },
      "modules.v1": `https://${event.requestContext.domainName}/registry/modules/v1/`,
      // TODO: check if we need to provide all of these, or if we can just include modules.v1
      "providers.v1": `https://${event.requestContext.domainName}/registry/providers/v1/`,
      "state.v2": "https://spacelift.sh/state.v2",
      "tfe.v2": "https://spacelift.sh/state.v2",
      "tfe.v2.1": "https://spacelift.sh/state.v2",
      "tfe.v2.2": "https://spacelift.sh/state.v2",
    }),
  };

  return response;
};
