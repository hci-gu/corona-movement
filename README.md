![wfh-movement-app](https://repository-images.githubusercontent.com/264223478/00232480-e7c8-11ea-9732-c0b2c5038e24)

WFH movement is a mobile application that lets users compare their physical activity before and after working from home. By selecting the date they did and uploading historical and current data from their phone or external activity tracking service they are presented with views to explore their data.

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

### WEB

```
cat << EOF > .env
REACT_APP_API=http://localhost:4000
EOF
```

### API

```
cat << EOF > .env
AWS_ACCESS_KEY_ID=AWS_ACCESS_KEY
AWS_SECRET_ACCESS_KEY=AWS_SECRET
EOF
```

- `serverless`
