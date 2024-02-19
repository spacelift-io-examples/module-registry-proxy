/* global fetch */
import { gzipSync } from "zlib";

export const handler = async (event) => {
  console.log("Received request for /{namespace}/{name}/{provider}/versions");

  const spaceliftBaseURL = process.env.SPACELIFT_BASE_URL;
  const spaceliftAccount = process.env.SPACELIFT_ACCOUNT_NAME;

  const spaceliftURL = `${spaceliftBaseURL}/registry/modules/v1/${spaceliftAccount}/${event.pathParameters.name}/${event.pathParameters.provider}/versions`;

  const encoding = event.headers["accept-encoding"];

  const spaceliftResponse = await fetch(spaceliftURL, {
    headers: {
      authorization: event.headers.authorization,
      "accept-encoding": encoding,
      "user-agent": event.headers["user-agent"],
      "x-terraform-version": event.headers["x-terraform-version"],
    },
  });

  let body = await spaceliftResponse.text();
  if (encoding === "gzip") {
    body = gzipSync(body).toString("base64");
  }

  const response = {
    statusCode: spaceliftResponse.status,
    headers: {},
    body: body,
    isBase64Encoded: encoding === "gzip",
  };

  for (const headerPair of spaceliftResponse.headers.entries()) {
    response.headers[headerPair[0]] = headerPair[1];
  }

  return response;
};
