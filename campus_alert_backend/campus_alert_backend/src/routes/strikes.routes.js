const express = require('express');
const { requireAuth } = require('../middleware/auth');
const { getStrikeNotice, acknowledgeStrike } = require('../controllers/strikes.controller');

const router = express.Router();

router.get('/:caseId', requireAuth, getStrikeNotice);
router.post('/:caseId/acknowledge', requireAuth, acknowledgeStrike);

module.exports = router;
