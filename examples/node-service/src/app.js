import Fastify from "fastify";
import fastifySwagger from "@fastify/swagger";
import fastifySwaggerUi from "@fastify/swagger-ui";

export function buildApp() {
  const app = Fastify({ logger: true });

  app.register(fastifySwagger, {
    openapi: {
      info: {
        title: "example-node-service",
        version: "1.0.0",
        description: "Reference Fastify service with OpenAPI/Swagger docs enabled."
      }
    }
  });

  app.register(fastifySwaggerUi, {
    routePrefix: "/docs"
  });

  app.get("/health", {
    schema: {
      summary: "Service health check",
      response: {
        200: {
          type: "object",
          properties: {
            status: { type: "string" }
          }
        }
      }
    }
  }, async () => ({ status: "ok" }));

  return app;
}
