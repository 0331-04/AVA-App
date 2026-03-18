/**
 * Email Utility - Send emails using Nodemailer
 * Setup for Gmail, but easily configurable for other providers
 */

const nodemailer = require('nodemailer');

const sendEmail = async (options) => {
  // Create transporter
  const transporter = nodemailer.createTransport({
    host: process.env.EMAIL_HOST || 'smtp.gmail.com',
    port: process.env.EMAIL_PORT || 587,
    secure: false, // true for 465, false for other ports
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASSWORD
    }
  });

  // Email templates
  const templates = {
    emailVerification: (data) => ({
      subject: options.subject,
      html: `
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .button { background: #4CAF50; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block; margin: 20px 0; }
            .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; font-size: 12px; color: #666; }
          </style>
        </head>
        <body>
          <div class="container">
            <h2>Welcome to AVA Insurance, ${data.name}!</h2>
            <p>Thank you for registering with AVA Insurance. Please verify your email address to activate your account.</p>
            <a href="${data.verificationUrl}" class="button">Verify Email</a>
            <p>Or copy and paste this link into your browser:</p>
            <p>${data.verificationUrl}</p>
            <p>This link will expire in 24 hours.</p>
            <div class="footer">
              <p>If you didn't create an account with AVA Insurance, please ignore this email.</p>
              <p>&copy; ${new Date().getFullYear()} AVA Insurance. All rights reserved.</p>
            </div>
          </div>
        </body>
        </html>
      `
    }),
    
    passwordReset: (data) => ({
      subject: options.subject,
      html: `
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .button { background: #f44336; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block; margin: 20px 0; }
            .warning { background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; }
            .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; font-size: 12px; color: #666; }
          </style>
        </head>
        <body>
          <div class="container">
            <h2>Password Reset Request</h2>
            <p>Hi ${data.name},</p>
            <p>We received a request to reset your password for your AVA Insurance account.</p>
            <a href="${data.resetUrl}" class="button">Reset Password</a>
            <p>Or copy and paste this link into your browser:</p>
            <p>${data.resetUrl}</p>
            <div class="warning">
              <strong>⚠️ Security Notice:</strong><br>
              This link will expire in ${data.expiryTime}. If you didn't request a password reset, please ignore this email or contact support if you have concerns.
            </div>
            <div class="footer">
              <p>&copy; ${new Date().getFullYear()} AVA Insurance. All rights reserved.</p>
            </div>
          </div>
        </body>
        </html>
      `
    })
  };

  // Get template
  const template = templates[options.template] 
    ? templates[options.template](options.data)
    : { subject: options.subject, html: options.message };

  // Email options
  const message = {
    from: `${process.env.EMAIL_FROM_NAME || 'AVA Insurance'} <${process.env.EMAIL_USER}>`,
    to: options.email,
    subject: template.subject,
    html: template.html
  };

  // Send email
  const info = await transporter.sendMail(message);

  console.log('Email sent: %s', info.messageId);
  return info;
};

module.exports = sendEmail;