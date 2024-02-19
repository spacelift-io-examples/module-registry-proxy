export const handler = async (event) => {
  console.log("Received request for well-known/terraform.json");

  var response = {
    statusCode: 200,
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      "modules.v1": `https://${event.requestContext.domainName}/registry/modules/v1/`,
    }),
  };

  return response;
};
