import Fastify from "fastify";
import fastifySwagger from "@fastify/swagger";
import fastifySwaggerUi from "@fastify/swagger-ui";

export function buildApp() {
  const app = Fastify({ logger: true });

  app.register(fastifySwagger, {
    openapi: {
      info: {
        title: "{{ service_name }}",
        version: "1.0.0",
        description: "Template Fastify service with OpenAPI/Swagger docs enabled."
      }
    }
  });

  app.register(fastifySwaggerUi, {
    routePrefix: "/docs"
  });

  app.get("/health", async () => ({ status: "ok" }));

  return app;
}
