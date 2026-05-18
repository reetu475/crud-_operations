import mongoose from "mongoose";

const operationLogSchema = new mongoose.Schema(
  {
    action: {
      type: String,
      enum: ["create", "read", "update", "delete"],
      required: true
    },
    itemId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Item",
      default: null
    },
    message: {
      type: String,
      required: true,
      trim: true
    }
  },
  {
    timestamps: true
  }
);

const OperationLog = mongoose.model("OperationLog", operationLogSchema);

export default OperationLog;
