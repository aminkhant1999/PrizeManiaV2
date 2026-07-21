const express = require('express');
const pageController = require('../controllers/pageController');

const router = express.Router();

router.get('/about', pageController.showAboutPage);
router.get('/contact', pageController.showContactPage);

module.exports = router;
