// 🔍 Security Audit Configuration for Chica's Chicken App

// OWASP ZAP Configuration
const owaspZapConfig = {
  // ZAP API configuration
  zapApiUrl: process.env.ZAP_API_URL || 'http://localhost:8080',
  zapApiKey: process.env.ZAP_API_KEY,
  
  // Target application URLs
  targetUrls: [
    process.env.API_BASE_URL || 'http://localhost:3000',
    process.env.FRONTEND_URL || 'http://localhost:8080'
  ],
  
  // Scan policies
  scanPolicies: {
    // Quick scan for CI/CD pipeline
    quick: {
      scanType: 'quick',
      maxDuration: 300, // 5 minutes
      alertThreshold: 'Medium'
    },
    
    // Full scan for comprehensive testing
    full: {
      scanType: 'full',
      maxDuration: 1800, // 30 minutes
      alertThreshold: 'Low'
    },
    
    // API-specific scan
    api: {
      scanType: 'api',
      maxDuration: 600, // 10 minutes
      alertThreshold: 'Medium',
      apiDefinition: '/api/docs/swagger.json'
    }
  },
  
  // Exclusions (URLs to skip during scanning)
  exclusions: [
    '/api/health',
    '/api/metrics',
    '/api/docs',
    '/static/',
    '/assets/'
  ],
  
  // Authentication configuration
  authentication: {
    method: 'form', // or 'header', 'script'
    loginUrl: '/api/auth/login',
    usernameField: 'email',
    passwordField: 'password',
    testCredentials: {
      username: process.env.TEST_USER_EMAIL,
      password: process.env.TEST_USER_PASSWORD
    }
  }
};

// Snyk Configuration
const snykConfig = {
  // Project settings
  projectId: process.env.SNYK_PROJECT_ID,
  orgId: process.env.SNYK_ORG_ID,
  
  // Scan settings
  scanSettings: {
    // Dependency vulnerabilities
    dependencies: {
      enabled: true,
      severity: ['high', 'critical'],
      failOnIssues: true
    },
    
    // Code vulnerabilities
    code: {
      enabled: true,
      severity: ['medium', 'high', 'critical'],
      failOnIssues: false // Don't fail build on code issues initially
    },
    
    // Container vulnerabilities
    container: {
      enabled: true,
      severity: ['high', 'critical'],
      failOnIssues: true
    },
    
    // Infrastructure as Code
    iac: {
      enabled: true,
      severity: ['medium', 'high', 'critical'],
      failOnIssues: false
    }
  },
  
  // Ignore policies
  ignorePatterns: [
    'node_modules/',
    'dist/',
    'build/',
    '*.test.js',
    '*.spec.js'
  ]
};

// Security Headers Configuration
const securityHeaders = {
  // Content Security Policy
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: [
        "'self'",
        "'unsafe-inline'", // Required for Flutter web
        "https://www.google.com/recaptcha/",
        "https://www.gstatic.com/recaptcha/"
      ],
      styleSrc: [
        "'self'",
        "'unsafe-inline'", // Required for Flutter web
        "https://fonts.googleapis.com"
      ],
      fontSrc: [
        "'self'",
        "https://fonts.gstatic.com"
      ],
      imgSrc: [
        "'self'",
        "data:",
        "https://res.cloudinary.com", // Image CDN
        "https://images.unsplash.com" // Placeholder images
      ],
      connectSrc: [
        "'self'",
        "https://api.stripe.com", // Payment processing
        "wss://localhost:*", // WebSocket for development
        "wss://*.herokuapp.com" // WebSocket for production
      ],
      frameSrc: [
        "https://www.google.com/recaptcha/"
      ]
    }
  },
  
  // Other security headers
  headers: {
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'X-XSS-Protection': '1; mode=block',
    'Referrer-Policy': 'strict-origin-when-cross-origin',
    'Permissions-Policy': 'geolocation=(), microphone=(), camera=()',
    'Strict-Transport-Security': 'max-age=31536000; includeSubDomains'
  }
};

// Vulnerability Scanning Schedule
const scanSchedule = {
  // Daily quick scans
  daily: {
    cron: '0 2 * * *', // 2 AM daily
    scanType: 'quick',
    notify: ['security-team@chicaschicken.com']
  },
  
  // Weekly full scans
  weekly: {
    cron: '0 3 * * 0', // 3 AM every Sunday
    scanType: 'full',
    notify: ['security-team@chicaschicken.com', 'dev-team@chicaschicken.com']
  },
  
  // Monthly comprehensive audit
  monthly: {
    cron: '0 4 1 * *', // 4 AM on 1st of every month
    scanType: 'comprehensive',
    notify: ['security-team@chicaschicken.com', 'management@chicaschicken.com']
  }
};

// Security Metrics Configuration
const securityMetrics = {
  // Metrics to track
  metrics: [
    'vulnerability_count',
    'security_incidents',
    'failed_login_attempts',
    'rate_limit_violations',
    'suspicious_activities',
    'captcha_failures'
  ],
  
  // Alerting thresholds
  thresholds: {
    critical_vulnerabilities: 0, // Alert on any critical vulnerability
    high_vulnerabilities: 5,
    failed_logins_per_hour: 50,
    rate_limit_violations_per_hour: 100,
    suspicious_activities_per_hour: 10
  },
  
  // Notification channels
  notifications: {
    slack: process.env.SLACK_WEBHOOK_URL,
    email: ['security-team@chicaschicken.com'],
    pagerduty: process.env.PAGERDUTY_INTEGRATION_KEY
  }
};

// Compliance Configuration
const complianceConfig = {
  // PCI DSS requirements
  pciDss: {
    enabled: true,
    requirements: [
      'network_security',
      'data_protection',
      'vulnerability_management',
      'access_control',
      'monitoring',
      'security_policies'
    ]
  },
  
  // GDPR requirements
  gdpr: {
    enabled: true,
    requirements: [
      'data_minimization',
      'consent_management',
      'data_portability',
      'right_to_erasure',
      'breach_notification'
    ]
  },
  
  // SOC 2 Type II
  soc2: {
    enabled: true,
    controls: [
      'security',
      'availability',
      'processing_integrity',
      'confidentiality',
      'privacy'
    ]
  }
};

module.exports = {
  owaspZapConfig,
  snykConfig,
  securityHeaders,
  scanSchedule,
  securityMetrics,
  complianceConfig
};
