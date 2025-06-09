const axios = require('axios');
const logger = require('../utils/logger');

// 🤖 Google reCAPTCHA Verification
const verifyCaptcha = async (req, res, next) => {
  try {
    const { captchaToken } = req.body;

    if (!captchaToken) {
      return res.status(400).json({
        success: false,
        error: 'CAPTCHA token is required'
      });
    }

    // Verify with Google reCAPTCHA
    const response = await axios.post('https://www.google.com/recaptcha/api/siteverify', null, {
      params: {
        secret: process.env.RECAPTCHA_SECRET_KEY,
        response: captchaToken,
        remoteip: req.ip
      }
    });

    const { success, score, action } = response.data;

    if (!success) {
      logger.warn(`CAPTCHA verification failed for IP: ${req.ip}`, response.data);
      return res.status(400).json({
        success: false,
        error: 'CAPTCHA verification failed'
      });
    }

    // For reCAPTCHA v3, check the score (0.0 to 1.0)
    if (score !== undefined && score < 0.5) {
      logger.warn(`Low CAPTCHA score (${score}) for IP: ${req.ip}`);
      return res.status(400).json({
        success: false,
        error: 'CAPTCHA verification failed - suspicious activity detected'
      });
    }

    // Log successful verification
    logger.info(`CAPTCHA verified successfully for IP: ${req.ip}`, {
      score,
      action
    });

    // Remove captcha token from request body before proceeding
    delete req.body.captchaToken;
    next();

  } catch (error) {
    logger.error('CAPTCHA verification error:', error);
    res.status(500).json({
      success: false,
      error: 'CAPTCHA verification service unavailable'
    });
  }
};

// 🔐 Enhanced CAPTCHA for High-Risk Operations
const verifyHighRiskCaptcha = async (req, res, next) => {
  try {
    const { captchaToken } = req.body;

    if (!captchaToken) {
      return res.status(400).json({
        success: false,
        error: 'CAPTCHA verification is required for this operation'
      });
    }

    const response = await axios.post('https://www.google.com/recaptcha/api/siteverify', null, {
      params: {
        secret: process.env.RECAPTCHA_SECRET_KEY,
        response: captchaToken,
        remoteip: req.ip
      }
    });

    const { success, score, action } = response.data;

    if (!success) {
      logger.warn(`High-risk CAPTCHA verification failed for IP: ${req.ip}`, response.data);
      return res.status(400).json({
        success: false,
        error: 'Security verification failed'
      });
    }

    // Higher threshold for high-risk operations
    if (score !== undefined && score < 0.7) {
      logger.warn(`Insufficient CAPTCHA score (${score}) for high-risk operation from IP: ${req.ip}`);
      return res.status(400).json({
        success: false,
        error: 'Additional security verification required'
      });
    }

    logger.info(`High-risk CAPTCHA verified successfully for IP: ${req.ip}`, {
      score,
      action
    });

    delete req.body.captchaToken;
    next();

  } catch (error) {
    logger.error('High-risk CAPTCHA verification error:', error);
    res.status(500).json({
      success: false,
      error: 'Security verification service unavailable'
    });
  }
};

// 📱 Mobile App CAPTCHA (Simplified)
const verifyMobileCaptcha = async (req, res, next) => {
  try {
    const { captchaToken, deviceId } = req.body;

    // For mobile apps, we might use device fingerprinting
    if (!captchaToken && !deviceId) {
      return res.status(400).json({
        success: false,
        error: 'Device verification required'
      });
    }

    if (captchaToken) {
      // Standard reCAPTCHA verification
      const response = await axios.post('https://www.google.com/recaptcha/api/siteverify', null, {
        params: {
          secret: process.env.RECAPTCHA_SECRET_KEY,
          response: captchaToken,
          remoteip: req.ip
        }
      });

      if (!response.data.success) {
        logger.warn(`Mobile CAPTCHA verification failed for IP: ${req.ip}`);
        return res.status(400).json({
          success: false,
          error: 'Verification failed'
        });
      }
    }

    // Additional device-based verification could be added here
    if (deviceId) {
      // Verify device ID against known patterns or blacklists
      logger.info(`Mobile device verification for device: ${deviceId}`);
    }

    delete req.body.captchaToken;
    next();

  } catch (error) {
    logger.error('Mobile CAPTCHA verification error:', error);
    res.status(500).json({
      success: false,
      error: 'Verification service unavailable'
    });
  }
};

// 🚨 Emergency Bypass (for testing/admin)
const bypassCaptcha = (req, res, next) => {
  if (process.env.NODE_ENV === 'development' && req.headers['x-bypass-captcha'] === 'true') {
    logger.warn('CAPTCHA bypassed for development');
    delete req.body.captchaToken;
    return next();
  }
  
  // In production, this should never bypass
  return verifyCaptcha(req, res, next);
};

module.exports = {
  verifyCaptcha,
  verifyHighRiskCaptcha,
  verifyMobileCaptcha,
  bypassCaptcha
};
