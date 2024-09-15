// controllers/blogController.js
const Blog = require('../models/Blog');

// Get all blogs
exports.getblogs = async (req, res) => {
  try {
    const blogs = await Blog.find({});
    res.status(200).json(blogs);
  } catch (error) {
    res.status(500).json({ error: 'An error occurred while fetching blogs' });
  }
};

// Create a new blog
exports.createblogs = async (req, res) => {
  try {
    const { title, content, author } = req.body;
    const newBlog = new Blog({ title, content, author });
    await newBlog.save();
    res.status(201).json(newBlog);
  } catch (error) {
    res.status(500).json({ error: 'An error occurred while creating the blog' });
  }
};

// Update an existing blog
exports.updateblogs = async (req, res) => {
  try {
    const { id, title, content, author } = req.body;
    const updatedBlog = await Blog.findByIdAndUpdate(
      id,
      { title, content, author },
      { new: true }
    );
    if (!updatedBlog) {
      return res.status(404).json({ error: 'Blog not found' });
    }
    res.status(200).json(updatedBlog);
  } catch (error) {
    res.status(500).json({ error: 'An error occurred while updating the blog' });
  }
};

// Delete a blog
exports.deleteblogs = async (req, res) => {
  try {
    const { id } = req.body;
    const deletedBlog = await Blog.findByIdAndDelete(id);
    if (!deletedBlog) {
      return res.status(404).json({ error: 'Blog not found' });
    }
    res.status(200).json({ message: 'Blog deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'An error occurred while deleting the blog' });
  }
};