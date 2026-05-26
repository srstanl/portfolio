# [Backstage](https://backstage.io)

This is your newly scaffolded Backstage App, Good Luck!

To start the app, run:

```sh
yarn install
yarn start
```

## Build Docker Image
From this `backstage-portal/` directory:

```sh
docker build -t backstage-portal:local .
docker run --rm -p 7007:7007 backstage-portal:local
```

Backend URL:
- `http://localhost:7007`
