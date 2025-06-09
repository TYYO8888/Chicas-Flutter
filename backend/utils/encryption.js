const crypto = require('crypto');
const bcrypt = require('bcrypt');
const logger = require('./logger');

// 🔐 Encryption Configuration
const ENCRYPTION_ALGORITHM = 'aes-256-gcm';
const KEY_LENGTH = 32; // 256 bits
const IV_LENGTH = 16; // 128 bits
const TAG_LENGTH = 16; // 128 bits
const SALT_ROUNDS = 12;

// Get encryption key from environment or generate one
const getEncryptionKey = () => {
  const key = process.env.ENCRYPTION_KEY;
  if (!key) {
    throw new Error('ENCRYPTION_KEY environment variable is required');
  }
  
  // Ensure key is the correct length
  return crypto.scryptSync(key, 'salt', KEY_LENGTH);
};

// 🔒 Encrypt sensitive data
const encryptData = (plaintext) => {
  try {
    if (!plaintext) return null;
    
    const key = getEncryptionKey();
    const iv = crypto.randomBytes(IV_LENGTH);
    const cipher = crypto.createCipher(ENCRYPTION_ALGORITHM, key);
    cipher.setAAD(Buffer.from('chicas-chicken-app'));
    
    let encrypted = cipher.update(plaintext, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    
    const tag = cipher.getAuthTag();
    
    // Combine IV, tag, and encrypted data
    const result = iv.toString('hex') + ':' + tag.toString('hex') + ':' + encrypted;
    
    return result;
  } catch (error) {
    logger.error('Encryption error:', error);
    throw new Error('Failed to encrypt data');
  }
};

// 🔓 Decrypt sensitive data
const decryptData = (encryptedData) => {
  try {
    if (!encryptedData) return null;
    
    const key = getEncryptionKey();
    const parts = encryptedData.split(':');
    
    if (parts.length !== 3) {
      throw new Error('Invalid encrypted data format');
    }
    
    const iv = Buffer.from(parts[0], 'hex');
    const tag = Buffer.from(parts[1], 'hex');
    const encrypted = parts[2];
    
    const decipher = crypto.createDecipher(ENCRYPTION_ALGORITHM, key);
    decipher.setAAD(Buffer.from('chicas-chicken-app'));
    decipher.setAuthTag(tag);
    
    let decrypted = decipher.update(encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    
    return decrypted;
  } catch (error) {
    logger.error('Decryption error:', error);
    throw new Error('Failed to decrypt data');
  }
};

// 🏠 Encrypt user address
const encryptAddress = (address) => {
  if (!address) return null;
  
  return {
    street: encryptData(address.street),
    city: encryptData(address.city),
    state: encryptData(address.state),
    zipCode: encryptData(address.zipCode),
    country: encryptData(address.country),
    // Keep non-sensitive fields unencrypted for queries
    coordinates: address.coordinates,
    isDefault: address.isDefault
  };
};

// 🏠 Decrypt user address
const decryptAddress = (encryptedAddress) => {
  if (!encryptedAddress) return null;
  
  return {
    street: decryptData(encryptedAddress.street),
    city: decryptData(encryptedAddress.city),
    state: decryptData(encryptedAddress.state),
    zipCode: decryptData(encryptedAddress.zipCode),
    country: decryptData(encryptedAddress.country),
    coordinates: encryptedAddress.coordinates,
    isDefault: encryptedAddress.isDefault
  };
};

// 💳 Encrypt payment information (PCI DSS compliant)
const encryptPaymentInfo = (paymentInfo) => {
  if (!paymentInfo) return null;
  
  // Note: In production, use a PCI DSS compliant service like Stripe
  return {
    // Only store last 4 digits and encrypted token
    lastFour: paymentInfo.cardNumber ? paymentInfo.cardNumber.slice(-4) : null,
    cardType: paymentInfo.cardType,
    expiryMonth: paymentInfo.expiryMonth,
    expiryYear: paymentInfo.expiryYear,
    // Store encrypted token from payment processor
    token: encryptData(paymentInfo.token),
    // Never store CVV
    billingAddress: encryptAddress(paymentInfo.billingAddress)
  };
};

// 💳 Decrypt payment information
const decryptPaymentInfo = (encryptedPaymentInfo) => {
  if (!encryptedPaymentInfo) return null;
  
  return {
    lastFour: encryptedPaymentInfo.lastFour,
    cardType: encryptedPaymentInfo.cardType,
    expiryMonth: encryptedPaymentInfo.expiryMonth,
    expiryYear: encryptedPaymentInfo.expiryYear,
    token: decryptData(encryptedPaymentInfo.token),
    billingAddress: decryptAddress(encryptedPaymentInfo.billingAddress)
  };
};

// 🔑 Hash passwords securely
const hashPassword = async (password) => {
  try {
    return await bcrypt.hash(password, SALT_ROUNDS);
  } catch (error) {
    logger.error('Password hashing error:', error);
    throw new Error('Failed to hash password');
  }
};

// 🔑 Verify password
const verifyPassword = async (password, hashedPassword) => {
  try {
    return await bcrypt.compare(password, hashedPassword);
  } catch (error) {
    logger.error('Password verification error:', error);
    throw new Error('Failed to verify password');
  }
};

// 🎲 Generate secure random token
const generateSecureToken = (length = 32) => {
  return crypto.randomBytes(length).toString('hex');
};

// 🔐 Generate API key
const generateApiKey = () => {
  const timestamp = Date.now().toString();
  const randomBytes = crypto.randomBytes(16).toString('hex');
  return `cc_${timestamp}_${randomBytes}`;
};

// 📱 Generate device fingerprint
const generateDeviceFingerprint = (userAgent, ip, additionalData = {}) => {
  const data = JSON.stringify({
    userAgent,
    ip,
    ...additionalData,
    timestamp: Date.now()
  });
  
  return crypto.createHash('sha256').update(data).digest('hex');
};

// 🛡️ Secure data sanitization
const sanitizeData = (data) => {
  if (typeof data === 'string') {
    // Remove potential XSS and injection attempts
    return data
      .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
      .replace(/javascript:/gi, '')
      .replace(/on\w+\s*=/gi, '')
      .trim();
  }
  
  if (typeof data === 'object' && data !== null) {
    const sanitized = {};
    for (const [key, value] of Object.entries(data)) {
      sanitized[key] = sanitizeData(value);
    }
    return sanitized;
  }
  
  return data;
};

module.exports = {
  encryptData,
  decryptData,
  encryptAddress,
  decryptAddress,
  encryptPaymentInfo,
  decryptPaymentInfo,
  hashPassword,
  verifyPassword,
  generateSecureToken,
  generateApiKey,
  generateDeviceFingerprint,
  sanitizeData
};
