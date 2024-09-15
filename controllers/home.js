/**
 * GET /
 * Home page.
 */
exports.index = (req, res) => {
  res.render('home', {
    title: 'Home'
  });
};

/** 
 * GET /blogs
 * Blogs page.
 */

exports.blogs = (req, res) => {
  res.render('blogs', {
    title: 'Blogs'
  });
}