# RoomMatch API

JSON-file backend for the RoomMatch Flutter app.

## Setup

```bash
cd server
npm install
npm start
```

API runs at `http://localhost:3000`.

## Seed account

On first start, user `usr_001` (`abebe@gmail.com`) gets password `password123`.

Register new accounts via the app or `POST /api/auth/register`.

## Endpoints

- `POST /api/auth/register` — body: `fullName`, `email`, `password`, `phone`, `gender`, `role` (`owner` | `tenant`)
- `POST /api/auth/login` — body: `email`, `password`
- `GET /api/users/:id`
- `PUT /api/users/:id` — multipart: optional `avatar`, fields `fullName`, `email`, `phone`, `bio`
- `GET /api/properties` — query: `search`, `maxBudget`, `propertyType`, `bedrooms`, `ownerId`, `verified`
- `GET /api/properties/:id`
- `POST /api/properties` — multipart: `images[]`, property fields (owner auth required)
- `PUT /api/properties/:id`
- `DELETE /api/properties/:id`

Uploaded files are served from `/uploads/...`.
