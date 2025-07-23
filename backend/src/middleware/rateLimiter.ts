import { RateLimiterMemory } from 'rate-limiter-flexible';
import { Request, Response, NextFunction } from 'express';

// Create rate limiter instance
const rateLimiterInstance = new RateLimiterMemory({
  keyPrefix: 'middleware',
  points: 100, // Number of requests
  duration: 900, // Per 15 minutes (900 seconds)
  blockDuration: 300, // Block for 5 minutes if limit exceeded
});

export const rateLimiter = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const key = req.ip || 'unknown';
    await rateLimiterInstance.consume(key);
    next();
  } catch (rejRes: any) {
    const remainingPoints = rejRes?.remainingPoints || 0;
    const msBeforeNext = rejRes?.msBeforeNext || 0;
    
    res.set({
      'Retry-After': Math.round(msBeforeNext / 1000) || 1,
      'X-RateLimit-Limit': 100,
      'X-RateLimit-Remaining': remainingPoints,
      'X-RateLimit-Reset': new Date(Date.now() + msBeforeNext).toISOString(),
    });
    
    res.status(429).json({
      success: false,
      error: {
        message: 'Too Many Requests',
        statusCode: 429,
        timestamp: new Date().toISOString(),
        retryAfter: Math.round(msBeforeNext / 1000),
      },
    });
  }
};