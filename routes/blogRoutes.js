const express = require('express');
const router = express.Router();
const blogController = require('../controllers/blogController');

// Define routes for blog posts
router.route('/blogs')
  .get(blogController.getblogs)
  .post(blogController.createblogs)
  .put(blogController.updateblogs)
  .delete(blogController.deleteblogs);

module.exports = router;