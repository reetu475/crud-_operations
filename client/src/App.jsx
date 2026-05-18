import React, { useEffect, useMemo, useState } from "react";
import { Check, List, Pencil, Plus, RefreshCcw, Trash2, X } from "lucide-react";

const API_URL = "http://localhost:5000/api/items";

const emptyForm = {
  title: "",
  description: ""
};

function App() {
  const [items, setItems] = useState([]);
  const [form, setForm] = useState(emptyForm);
  const [editingId, setEditingId] = useState(null);
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const isEditing = useMemo(() => Boolean(editingId), [editingId]);

  const showSuccess = (message) => {
    setSuccess(message);
    window.setTimeout(() => setSuccess(""), 2500);
  };

  const fetchItems = async (showMessage = false) => {
    try {
      setLoading(true);
      setError("");

      const response = await fetch(API_URL);
      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || "Could not load data");
      }

      setItems(data);
      if (showMessage) {
        showSuccess("Items read from MongoDB.");
      }
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchItems();
  }, []);

  const handleChange = (event) => {
    const { name, value } = event.target;
    setForm((current) => ({ ...current, [name]: value }));
  };

  const resetForm = () => {
    setForm(emptyForm);
    setEditingId(null);
  };

  const handleSubmit = async (event) => {
    event.preventDefault();

    if (!form.title.trim()) {
      setError("Title cannot be empty.");
      return;
    }

    try {
      setSaving(true);
      setError("");

      const response = await fetch(isEditing ? `${API_URL}/${editingId}` : API_URL, {
        method: isEditing ? "PUT" : "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify(form)
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || "Could not save data");
      }

      if (isEditing) {
        setItems((current) => current.map((item) => (item._id === editingId ? data : item)));
        showSuccess("Item updated in MongoDB.");
      } else {
        setItems((current) => [data, ...current]);
        showSuccess("Item added to MongoDB.");
      }

      resetForm();
    } catch (err) {
      setError(err.message);
    } finally {
      setSaving(false);
    }
  };

  const startEdit = (item) => {
    setEditingId(item._id);
    setForm({
      title: item.title,
      description: item.description || ""
    });
    setError("");
  };

  const deleteItem = async (id) => {
    try {
      setError("");

      const response = await fetch(`${API_URL}/${id}`, {
        method: "DELETE"
      });
      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || "Could not delete item");
      }

      setItems((current) => current.filter((item) => item._id !== id));
      showSuccess("Item deleted from MongoDB.");

      if (editingId === id) {
        resetForm();
      }
    } catch (err) {
      setError(err.message);
    }
  };

  return (
    <main className="app-shell">
      <section className="workspace">
        <div className="topbar">
          <div>
            <p className="eyebrow">MERN CRUD</p>
            <h1>Items</h1>
          </div>
          <button className="icon-button" onClick={() => fetchItems(true)} disabled={loading} title="Refresh data">
            <RefreshCcw size={18} />
          </button>
        </div>

        <form className="editor" onSubmit={handleSubmit}>
          <label>
            Title
            <input
              name="title"
              value={form.title}
              onChange={handleChange}
              placeholder="Enter item title"
              maxLength="80"
            />
          </label>

          <label>
            Description
            <textarea
              name="description"
              value={form.description}
              onChange={handleChange}
              placeholder="Enter item description"
              rows="3"
              maxLength="240"
            />
          </label>

          <div className="actions">
            <button className="primary" type="submit" disabled={saving}>
              {isEditing ? <Check size={18} /> : <Plus size={18} />}
              {isEditing ? "Update" : "Create"}
            </button>
            {isEditing && (
              <button className="secondary" type="button" onClick={resetForm}>
                <X size={18} />
                Cancel
              </button>
            )}
          </div>
        </form>

        {error && <p className="status error">{error}</p>}
        {success && <p className="status success">{success}</p>}

        <div className="list-header">
          <h2>Saved data</h2>
          <div className="read-actions">
            <span>{items.length} total</span>
            <button className="secondary" type="button" onClick={() => fetchItems(true)} disabled={loading}>
              <List size={18} />
              Read Items
            </button>
          </div>
        </div>

        {loading ? (
          <p className="empty-state">Loading data...</p>
        ) : items.length === 0 ? (
          <p className="empty-state">No data saved yet.</p>
        ) : (
          <ul className="item-list">
            {items.map((item) => (
              <li className="item-card" key={item._id}>
                <div>
                  <h3>{item.title}</h3>
                  <p>{item.description || "No description"}</p>
                </div>
                <div className="item-actions">
                  <button className="icon-button" onClick={() => startEdit(item)} title="Edit item">
                    <Pencil size={17} />
                  </button>
                  <button className="danger-button" onClick={() => deleteItem(item._id)} title="Delete item">
                    <Trash2 size={17} />
                  </button>
                </div>
              </li>
            ))}
          </ul>
        )}
      </section>
    </main>
  );
}

export default App;
