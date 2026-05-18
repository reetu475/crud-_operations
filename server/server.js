import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import mongoose from "mongoose";
import itemRoutes from "./src/routes/itemRoutes.js";

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.json({ message: "CRUD API is running" });
});

app.use("/api/items", itemRoutes);

let isConnected = false;

const connectDB = async () => {
  if (isConnected) return;
  if (!process.env.MONGODB_URI || process.env.MONGODB_URI.includes("your_mongodb")) {
    throw new Error("Please set a valid MONGODB_URI");
  }
  await mongoose.connect(process.env.MONGODB_URI);
  isConnected = true;
};

// For local dev
if (process.env.NODE_ENV !== "production") {
  const PORT = process.env.PORT || 5000;
  connectDB()
    .then(() => {
      console.log("MongoDB connected");
      app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
    })
    .catch((err) => {
      console.error("MongoDB connection failed:", err.message);
      process.exit(1);
    });
}

// Vercel serverless handler
export default async function handler(req, res) {
  await connectDB();
  return app(req, res);
}
