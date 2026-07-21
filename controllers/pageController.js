function showAboutPage(req, res) {
  res.render('page', {
    pageTitle: 'About PrizeMania',
    currentPath: req.path,
    heading: 'About PrizeMania',
    message: 'PrizeMania is a modern monthly lucky draw platform designed to give every participant a fair chance to win exciting prizes.',
    buttonText: 'Return to home',
    buttonHref: '/'
  });
}

function showContactPage(req, res) {
  res.render('page', {
    pageTitle: 'Contact PrizeMania',
    currentPath: req.path,
    heading: 'Contact PrizeMania',
    message: 'Have questions? Reach out to our support team and we will respond as soon as possible.',
    buttonText: 'Return to home',
    buttonHref: '/'
  });
}

function showRegisterPage(req, res) {
  res.render('page', {
    pageTitle: 'Register | PrizeMania',
    currentPath: req.path,
    heading: 'Create Your PrizeMania Account',
    message: 'Register to start collecting lucky draw tickets and enter the monthly prize draw.',
    buttonText: 'Return to home',
    buttonHref: '/'
  });
}

function showLoginPage(req, res) {
  res.render('page', {
    pageTitle: 'Login | PrizeMania',
    currentPath: req.path,
    heading: 'User Login',
    message: 'Login to manage your tickets, view draw history, and track your entries.',
    buttonText: 'Return to home',
    buttonHref: '/'
  });
}

function showAdminLoginPage(req, res) {
  res.render('page', {
    pageTitle: 'Admin Login | PrizeMania',
    currentPath: req.path,
    heading: 'Admin Login',
    message: 'Admins can log in to review contests, winners, and user activity.',
    buttonText: 'Return to home',
    buttonHref: '/'
  });
}

module.exports = {
  showAboutPage,
  showContactPage,
  showRegisterPage,
  showLoginPage,
  showAdminLoginPage
};
