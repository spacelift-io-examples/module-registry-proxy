/* global fetch */
import { gzipSync } from "zlib";

export const handler = async (event) => {
  console.log("Received request for /{namespace}/{name}/{provider}/versions");

  const spaceliftBaseURL = process.env.SPACELIFT_BASE_URL;
  const spaceliftAccount = process.env.SPACELIFT_ACCOUNT_NAME;

  const spaceliftURL = `${spaceliftBaseURL}/registry/modules/v1/${spaceliftAccount}/${event.pathParameters.name}/${event.pathParameters.provider}/versions`;

  console.log(`Making a request for ${spaceliftURL}`);

  const spaceliftResponse = await fetch(spaceliftURL, {
    headers: {
      authorization: event.headers.authorization,
      "accept-encoding": event.headers["accept-encoding"],
      "user-agent": event.headers["user-agent"],
      "x-terraform-version": event.headers["x-terraform-version"],
    },
  });

  // TODO: only do this if gzip encoding is requested
  const body = await spaceliftResponse.text();
  const compressedBody = gzipSync(body);

  const response = {
    statusCode: spaceliftResponse.status,
    headers: {},
    body: compressedBody.toString("base64"),
    isBase64Encoded: true,
  };

  for (const headerPair of spaceliftResponse.headers.entries()) {
    response.headers[headerPair[0]] = headerPair[1];
  }

  return response;
};
