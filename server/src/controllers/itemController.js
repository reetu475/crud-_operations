import mongoose from "mongoose";
import Item from "../models/Item.js";
import OperationLog from "../models/OperationLog.js";

const isBlank = (value) => !value || value.trim().length === 0;

const isInvalidId = (id) => !mongoose.Types.ObjectId.isValid(id);

export const getItems = async (req, res) => {
  try {
    const items = await Item.find().sort({ createdAt: -1 });
    await OperationLog.create({
      action: "read",
      message: `Read ${items.length} item${items.length === 1 ? "" : "s"}`
    });

    res.status(200).json(items);
  } catch (error) {
    res.status(500).json({ message: "Failed to read items", error: error.message });
  }
};

export const createItem = async (req, res) => {
  try {
    const { title, description = "" } = req.body;

    if (isBlank(title)) {
      return res.status(400).json({ message: "Title cannot be empty" });
    }

    const item = await Item.create({
      title: title.trim(),
      description: description.trim()
    });
    await OperationLog.create({
      action: "create",
      itemId: item._id,
      message: `Created item: ${item.title}`
    });

    res.status(201).json(item);
  } catch (error) {
    res.status(500).json({ message: "Failed to create item", error: error.message });
  }
};

export const updateItem = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description = "" } = req.body;

    if (isInvalidId(id)) {
      return res.status(400).json({ message: "Invalid item id" });
    }

    if (isBlank(title)) {
      return res.status(400).json({ message: "Title cannot be empty" });
    }

    const item = await Item.findByIdAndUpdate(
      id,
      {
        title: title.trim(),
        description: description.trim()
      },
      { new: true, runValidators: true }
    );

    if (!item) {
      return res.status(404).json({ message: "Item not found" });
    }

    await OperationLog.create({
      action: "update",
      itemId: item._id,
      message: `Updated item: ${item.title}`
    });

    res.status(200).json(item);
  } catch (error) {
    res.status(500).json({ message: "Failed to update item", error: error.message });
  }
};

export const deleteItem = async (req, res) => {
  try {
    const { id } = req.params;

    if (isInvalidId(id)) {
      return res.status(400).json({ message: "Invalid item id" });
    }

    const item = await Item.findByIdAndDelete(id);

    if (!item) {
      return res.status(404).json({ message: "Item not found" });
    }

    await OperationLog.create({
      action: "delete",
      itemId: item._id,
      message: `Deleted item: ${item.title}`
    });

    res.status(200).json({ message: "Item deleted successfully", item });
  } catch (error) {
    res.status(500).json({ message: "Failed to delete item", error: error.message });
  }
};
