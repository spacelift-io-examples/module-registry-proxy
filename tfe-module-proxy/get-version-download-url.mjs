/* global fetch */
export const handler = async (event) => {
  console.log(
    "Received request for /{namespace}/{name}/{provider}/{version}/download"
  );

  const spaceliftBaseURL = process.env.SPACELIFT_BASE_URL;
  const spaceliftAccount = process.env.SPACELIFT_ACCOUNT_NAME;

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
