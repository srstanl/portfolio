import { test } from "node:test";
import assert from "node:assert/strict";

import { buildApp } from "../src/app.js";

test("GET /health returns ok", async () => {
  const app = buildApp();

  const response = await app.inject({
    method: "GET",
    url: "/health"
  });

  assert.equal(response.statusCode, 200);
  assert.deepEqual(response.json(), { status: "ok" });

  await app.close();
});

test("GET /docs/json returns OpenAPI document", async () => {
  const app = buildApp();

  const response = await app.inject({
    method: "GET",
    url: "/docs/json"
  });

  assert.equal(response.statusCode, 200);
  assert.equal(response.json().openapi, "3.0.3");

  await app.close();
});
