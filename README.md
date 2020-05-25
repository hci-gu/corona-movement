# corona-movement

## Running the project

Dependencies

- `docker-compose up`
- `nvm use`

### API

- `cd api`

```
cat << EOF > .env
DB=mongo # or elastic
CONNECT_TO=mongodb://username:password@localhost:27017
EOF
```

- `npm i`
- `npm start`

### APP

- `cd app`
- Update `./lib/api.dart` with `const API_URL = 'http://your-local-ip:4000';`
- `flutter run`

### WEB

- `cd web`
- `npm i`
- `npm start`

## Deploy

### API

```
cat << EOF > .env
AWS_ACCESS_KEY_ID=AWS_ACCESS_KEY
AWS_SECRET_ACCESS_KEY=AWS_SECRET
EOF
```

- `serverless`
