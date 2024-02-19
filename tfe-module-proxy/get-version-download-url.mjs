// TODO: allow the Spacelift URL to be passed via an input parameter
// TODO: allow the Spacelift account name to be passed via an input parameter
// TODO: remove logging of event data

/* global fetch */
export const handler = async (event) => {
  console.log(
    "Received request for /{namespace}/{name}/{provider}/{version}/download"
  );

  // TODO: pull these from environment vars
  const spaceliftBaseURL = "https://spacelift.sh";
  const spaceliftAccount = "spaceliftsh";

  const spaceliftURL = `${spaceliftBaseURL}/registry/modules/v1/${spaceliftAccount}/${event.pathParameters.name}/${event.pathParameters.provider}/${event.pathParameters.version}/download`;

  console.log(`Making a request for ${spaceliftURL}`);

  const authHeader = event.headers.authorization;

  const spaceliftResponse = await fetch(spaceliftURL, {
    headers: {
      authorization: authHeader,
    },
  });
  const body = await spaceliftResponse.text();

  const response = {
    statusCode: spaceliftResponse.status,
    headers: {},
    body: body,
  };

  for (const headerPair of spaceliftResponse.headers.entries()) {
    response.headers[headerPair[0]] = headerPair[1];
  }

  return response;
};
