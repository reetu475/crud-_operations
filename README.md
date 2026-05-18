# MERN CRUD Basic App

A simple React + Node.js + MongoDB application that creates, reads, updates, and deletes items using Mongoose.

## Setup

1. Install dependencies:

```bash
npm run install-all
```

2. Add your MongoDB connection string in `server/.env`:

```env
MONGODB_URI=your_mongodb_connection_string_here
PORT=5000
```

3. Run the frontend and backend together:

```bash
npm run dev
```

4. Open the React app:

```text
http://localhost:5173
```

The backend runs at:

```text
http://localhost:5000
```

## API Routes

- `GET /api/items` - read all items
- `POST /api/items` - create an item
- `PUT /api/items/:id` - update an item
- `DELETE /api/items/:id` - delete an item

The UI updates immediately after each successful create, update, or delete operation. MongoDB is changed through the backend API, so the database will reflect the same data shown in the UI.
