const winnerModel = require('../models/winnerModel');
const prizeModel = require('../models/prizeModel');
const drawModel = require('../models/drawModel');

function formatWinnerMonth(value) {
  if (!value) {
    return "Date unavailable";
  }

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) {
    return "Date unavailable";
  }

  return new Intl.DateTimeFormat("en-GB", {
    month: "long",
    year: "numeric"
  }).format(date);
}

async function showHomePage(req, res, next) {
  try {
    const [winnerRows, prizes, currentDraw] = await Promise.all([
      winnerModel.getPublishedWinners(), prizeModel.listActive(), drawModel.getOpen()
    ]);

    const winners = winnerRows.map((winner) => ({
      ...winner,
      monthLabel: formatWinnerMonth(winner.month)
    }));

    res.render('home', {
      pageTitle: 'PrizeMania | Home',
      currentPath: req.path,
      prizes,
      winners,
      currentDraw
    });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  showHomePage
};
