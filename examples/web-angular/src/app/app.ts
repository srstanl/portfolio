import { Component } from '@angular/core';

interface ServiceCard {
  name: string;
  description: string;
  healthUrl: string;
  docsUrl: string;
  openApiUrl: string;
}

@Component({
  selector: 'app-root',
  standalone: true,
  templateUrl: './app.html',
  styleUrl: './app.scss'
})
export class App {
  protected readonly services: ServiceCard[] = [
    {
      name: '.NET Service',
      description: 'ASP.NET Core 10 API with Swagger and analyzer-first defaults.',
      healthUrl: 'http://localhost:5000/health',
      docsUrl: 'http://localhost:5000/swagger',
      openApiUrl: 'http://localhost:5000/swagger/v1/swagger.json'
    },
    {
      name: 'Python Service',
      description: 'FastAPI reference API with OpenAPI-first contract publishing.',
      healthUrl: 'http://localhost:8080/health',
      docsUrl: 'http://localhost:8080/docs',
      openApiUrl: 'http://localhost:8080/openapi.json'
    },
    {
      name: 'Node Service',
      description: 'Fastify API with Swagger UI and JSON schema-driven routes.',
      healthUrl: 'http://localhost:8080/health',
      docsUrl: 'http://localhost:8080/docs',
      openApiUrl: 'http://localhost:8080/docs/json'
    }
  ];
}
