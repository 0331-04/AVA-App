# 🔐 AVA Insurance - Authentication System

## Executive Summary

The AVA Insurance Authentication System provides a comprehensive, secure, and scalable user authentication solution built on industry-standard technologies. The system implements JSON Web Token (JWT) based authentication with refresh token support, email verification workflows, password reset functionality, and role-based access control. This implementation ensures secure access to the platform while maintaining a seamless user experience across all touchpoints.

## Problem Statement

Traditional authentication systems in insurance platforms face significant challenges that impact both security and user experience. Users frequently struggle with complex password requirements leading to forgotten credentials and account lockouts. The absence of automated verification processes creates opportunities for fraudulent account creation. Manual password reset procedures introduce delays and security vulnerabilities. Limited session management capabilities fail to balance security requirements with user convenience. The lack of granular permission controls prevents effective implementation of least-privilege access principles across different user roles within insurance organizations.

## Solution Architecture

The authentication system addresses these challenges through a multi-layered approach combining modern security practices with user-friendly workflows. At the foundation, bcrypt password hashing with configurable work factors ensures credential security even in the event of database compromise. JSON Web Tokens provide stateless authentication that scales horizontally without session storage overhead. Refresh tokens enable long-lived sessions while maintaining the ability to revoke access when necessary. Email verification workflows using time-limited tokens confirm user identity during registration. Password reset functionality employs secure token generation and expiration to prevent unauthorized account access. Role-based access control implements fine-grained permissions across customer, claim officer, assessor, and administrator roles.

## Technical Implementation

The system architecture comprises three primary layers working in concert to deliver secure authentication. The model layer, implemented through Mongoose schemas, defines user data structures including credentials, verification status, and role assignments. Password hashing occurs automatically through pre-save middleware, ensuring no plaintext passwords ever persist to the database. The controller layer implements business logic for registration, login, token generation, email verification, and password management. Each operation includes comprehensive validation and error handling to prevent common security vulnerabilities. The middleware layer provides route protection through JWT verification and role-based authorization, ensuring only authenticated users with appropriate permissions can access protected resources.

## Core Features

### User Registration

The registration process accepts user details including name, email, password, phone number, National Identity Card number, and address information. Upon submission, the system validates all inputs against defined schemas and business rules. Passwords undergo bcrypt hashing with a work factor of ten, balancing security with performance. A verification email containing a time-limited token dispatches to the provided email address. The user account remains in an unverified state until the verification link is accessed, preventing unauthorized account creation through disposable email addresses.

### User Login

Authentication occurs through email and password credentials submitted to the login endpoint. The system retrieves the user record and compares the provided password against the stored hash using constant-time comparison to prevent timing attacks. Upon successful authentication, the system generates both an access token with seven-day expiration and a refresh token valid for thirty days. The response includes the access token, refresh token, and user profile information excluding sensitive fields. Failed login attempts increment a counter, triggering account lockout after five consecutive failures to prevent brute force attacks.

### Email Verification

Users receive verification emails containing unique tokens generated through cryptographic random number generation. These tokens include embedded user identifiers and expiration timestamps set for twenty-four hours from generation. Clicking the verification link triggers a request to the verification endpoint with the token parameter. The system validates the token format, checks expiration, and marks the user account as verified. Verified status gates access to certain platform features, ensuring email authenticity before granting full access.

### Password Reset

The password reset workflow initiates when users request a reset through their registered email address. The system generates a secure reset token and stores a hashed version in the user record with a one-hour expiration. An email containing a link with the reset token dispatches to the user's address. Accessing the link presents a password reset form where users enter their new password. Token validation ensures authenticity and freshness before allowing password updates. The new password undergoes the same hashing process as initial registration, and the reset token is immediately invalidated to prevent reuse.

### Token Refresh

Long-lived sessions utilize refresh tokens to obtain new access tokens without requiring re-authentication. When an access token expires, clients submit their refresh token to the refresh endpoint. The system validates the refresh token signature, checks expiration, and verifies the associated user account remains active. Upon successful validation, a new access token generates and returns to the client. Refresh tokens themselves can be revoked administratively, enabling immediate session termination when security requires.

### Role-Based Access Control

The system implements four distinct user roles with hierarchical permissions. Customers represent end users filing claims and managing their policies. Claim officers review submissions and make approval decisions on standard claims. Assessors provide specialized expertise on complex damage evaluations and high-value claims. Administrators possess full system access including user management, configuration changes, and audit log review. The authorization middleware enforces these roles at the route level, preventing unauthorized access to administrative functions.

## API Endpoints

### POST /api/auth/register

Creates a new user account with provided credentials and profile information. The endpoint accepts a JSON payload containing firstName, lastName, email, password, phone, nic, and address fields. Upon successful registration, the system returns the user profile along with access and refresh tokens. A verification email dispatches asynchronously to avoid blocking the response. The default role assignment is customer, with elevated roles requiring administrative approval.

Request body structure includes firstName and lastName as string fields with maximum length constraints. The email field must contain a valid email format and remain unique across all users. Password requirements enforce minimum length of eight characters with no maximum constraint. The phone field expects a ten-digit numeric string matching Sri Lankan mobile number formats. The nic field accepts either nine digits followed by V or X, or twelve numeric digits matching new Sri Lankan NIC formats. The address object contains street, city, and zipCode fields, all optional but recommended for complete profile information.

Response structure upon success includes a success boolean set to true, an accessToken string containing the JWT access token, a refreshToken string for session renewal, and a user object containing id, firstName, lastName, email, phone, nic, role, isVerified status, and createdAt timestamp. Error responses include a success boolean set to false, an error string describing the error category, and a message string providing specific details about the validation failure or system error.

### POST /api/auth/login

Authenticates existing users through email and password credentials. The endpoint validates credentials against stored hashes and returns authentication tokens upon success. Failed attempts increment a failure counter, triggering account lockout after five consecutive failures within a fifteen-minute window. The response includes user profile information and both access and refresh tokens for session management.

Request body requires email in valid format and password as provided during registration. The system performs case-insensitive email matching to accommodate user input variations. Password comparison uses bcrypt's constant-time comparison algorithm to prevent timing-based attacks.

Successful authentication returns the same structure as registration including tokens and user profile. Additionally, the response sets an HTTP-only cookie containing the refresh token for web-based clients. This cookie includes secure and sameSite flags when running in production mode, preventing cross-site request forgery attacks.

### GET /api/auth/me

Retrieves the currently authenticated user's profile information. This endpoint requires a valid JWT token in the Authorization header using Bearer scheme. The endpoint returns comprehensive profile data including personal information, policy details, registered vehicles, and account status indicators.

No request body is necessary as authentication occurs through the Authorization header. The protect middleware extracts the user identifier from the validated JWT and populates the request object with user details.

Response includes all public profile fields while excluding sensitive information such as password hashes, reset tokens, and internal identifiers. The vehicles array contains all registered vehicles with make, model, year, licensePlate, and color information. Policy information includes policyNumber, policyStartDate, policyEndDate, and computed status indicators.

### PUT /api/auth/updatedetails

Enables authenticated users to modify their profile information excluding password and email. The endpoint accepts partial updates, applying only provided fields while leaving others unchanged. This approach allows targeted updates without requiring the client to submit the complete profile.

Request body accepts optional firstName, lastName, phone, and address fields. Each field undergoes validation according to its schema definition. The address field, when provided, must include all subfields or none, preventing partial address updates that could create inconsistent data.

Successful updates return the modified user profile with the same structure as the me endpoint. The response reflects all changes immediately, as the database update uses the new parameter to return the modified document rather than the original.

### PUT /api/auth/updatepassword

Allows authenticated users to change their password while logged in. This differs from password reset in that it requires knowledge of the current password, providing defense against unauthorized changes when a session remains active but unattended.

Request body requires currentPassword and newPassword fields. The system verifies the current password matches the stored hash before proceeding with the update. The new password undergoes the same validation as initial registration and must differ from the current password.

Upon successful password change, all existing tokens remain valid. Administrators concerned about security may implement additional logic to invalidate existing sessions, forcing re-authentication across all devices. The response confirms the operation completed successfully without returning tokens, as the existing session continues.

### POST /api/auth/forgotpassword

Initiates the password reset workflow for users who cannot access their accounts. The endpoint accepts only an email address and initiates token generation and email dispatch regardless of whether the email exists in the database. This approach prevents email enumeration attacks that could identify valid user accounts.

Request body contains only the email field. The system queries for a user with the provided email address. When found, it generates a reset token, stores the hashed version in the user record, and sends an email with reset instructions. When not found, it delays for a constant time before responding to prevent timing-based account discovery.

Response indicates success in all cases to prevent information disclosure. The actual email send operation occurs asynchronously to avoid blocking the HTTP response. Users receive a consistent message instructing them to check their email regardless of account existence.

### PUT /api/auth/resetpassword/:token

Completes the password reset workflow by accepting the reset token and new password. The endpoint validates the token, checks expiration, and updates the password when all validations pass. This operation invalidates the reset token immediately to prevent reuse even within the expiration window.

Request parameters include the token in the URL path. Request body contains the new password field which undergoes standard password validation. The system extracts the user identifier from the token, retrieves the user record, and compares the token against the stored hash.

Successful password reset returns authentication tokens, automatically logging the user in with their new credentials. This eliminates the additional step of navigating to the login page after reset completion. The reset token field in the user record clears, and any existing sessions may optionally be invalidated based on security requirements.

### POST /api/auth/logout

Terminates the current user session by clearing authentication cookies and optionally invalidating the refresh token. For JWT-based stateless authentication, logout primarily serves to clear client-side tokens and provide a clear logout action in the user interface.

No request body is required as the endpoint operates on the authenticated session. The middleware identifies the user from the JWT token in the Authorization header.

Response confirms logout completion and clears any HTTP-only cookies containing refresh tokens. Client applications should discard stored access tokens upon receiving the logout confirmation. Server-side token invalidation could be implemented through a token blacklist, though this introduces state management complexity contrary to JWT's stateless design.

### POST /api/auth/refresh

Generates a new access token using a valid refresh token. This endpoint enables long-lived sessions without requiring frequent re-authentication while maintaining the security benefits of short-lived access tokens. The refresh operation validates the refresh token and issues a new access token with the standard expiration period.

Request body contains the refreshToken string originally provided during login or registration. The system validates the token signature, checks expiration, and ensures the associated user account remains active and uncompromised.

Successful refresh returns a new accessToken with seven-day expiration. The refresh token itself remains unchanged, continuing its validity until the thirty-day expiration. Some implementations rotate refresh tokens on each use, issuing a new refresh token alongside the access token to enable long-running sessions while maintaining revocation capabilities.

## Security Features

### Password Hashing

All passwords undergo bcrypt hashing before database persistence. Bcrypt's adaptive hash function incorporates a salt automatically, preventing rainbow table attacks and ensuring identical passwords generate different hashes. The work factor of ten balances security with server performance, taking approximately one hundred milliseconds per hash on modern hardware. This timing serves as a natural rate limiter on authentication attempts while remaining imperceptible to legitimate users.

### JWT Token Security

Access tokens contain user identifier and role information signed with a server secret key. The signature prevents tampering, as any modification to the token payload invalidates the signature. Tokens include an expiration timestamp, automatically invalidating after seven days even if stolen. The stateless nature of JWTs eliminates session storage requirements, enabling horizontal scaling without session replication.

### Rate Limiting

The authentication endpoints implement rate limiting through express-rate-limit middleware. Login attempts are restricted to five requests per fifteen minutes per IP address. This prevents brute force attacks while accommodating legitimate users who might mistype their password several times. Registration endpoints use similar limiting to prevent automated account creation.

### Account Lockout

After five consecutive failed login attempts, user accounts enter a locked state preventing further authentication for thirty minutes. This lockout occurs regardless of IP address, protecting against distributed brute force attacks using multiple IP addresses. Users receive notification of the lockout and may contact support for immediate unlock if necessary.

### Email Verification

Unverified accounts face restrictions on certain platform features, ensuring email address authenticity before granting full access. Verification tokens incorporate cryptographically random values resistant to prediction or brute force. The twenty-four-hour expiration window balances security with user convenience, as most users verify within hours of registration.

## Database Schema

The User model represents the core authentication entity with comprehensive fields supporting the authentication workflows. The schema defines firstName and lastName as required strings with maximum length constraints. The email field enforces uniqueness, employs lowercase conversion, and validates format through regular expression matching. The password field contains the bcrypt hash with automatic hashing on save through pre-save middleware. The select option defaults to false, excluding password hashes from query results unless explicitly requested.

Phone and nic fields include format validation through regular expressions ensuring data quality. The role field uses enumeration restricting values to customer, claim_officer, assessor, and admin with customer as default. Email verification tracking occurs through isVerified boolean and verifyEmailToken fields. Password reset functionality utilizes resetPasswordToken and resetPasswordExpire fields storing hashed tokens and expiration timestamps.

The vehicles array enables users to register multiple vehicles under their account. Each vehicle subdocument includes make, model, year, licensePlate, vin, color, and registrationDate fields. The licensePlate field must be unique across all users' vehicles, preventing duplicate vehicle registration.

Policy information resides directly on the user document through policyNumber, policyStartDate, and policyEndDate fields. This denormalization improves read performance for frequently accessed policy status checks. Timestamps track account creation and modification through createdAt and updatedAt fields managed automatically by Mongoose.

## Environment Configuration

The authentication system requires several environment variables configured in the .env file. NODE_ENV determines the runtime environment with development or production values affecting cookie security flags and error verbosity. MONGODB_URI contains the complete MongoDB connection string including authentication credentials and database name.

JWT_SECRET holds the signing key for access tokens and should contain at least thirty-two random characters. Reusing this secret across environments compromises security. JWT_EXPIRE defines access token lifetime using time notation such as 7d for seven days or 24h for twenty-four hours. JWT_COOKIE_EXPIRE specifies cookie expiration in days when using cookie-based token storage.

REFRESH_TOKEN_SECRET provides a separate signing key for refresh tokens, enabling independent revocation of access and refresh tokens. REFRESH_TOKEN_EXPIRE sets refresh token lifetime, typically longer than access tokens to support extended sessions.

Email configuration includes EMAIL_HOST, EMAIL_PORT, EMAIL_USER, and EMAIL_PASSWORD for SMTP server connection. EMAIL_FROM_NAME sets the sender name appearing in verification and reset emails. For production deployments, consider using dedicated email services rather than personal email accounts.

## Integration Guide

Integrating the authentication system into client applications requires implementing several key workflows. During user registration, clients submit user details to the registration endpoint and handle the response containing tokens. Storing the access token in memory or session storage balances security with functionality. The refresh token belongs in HTTP-only cookies or secure device storage to prevent theft through cross-site scripting attacks.

Login workflows follow a similar pattern, submitting credentials and storing returned tokens. Clients should implement automatic token refresh when receiving unauthorized responses, attempting to obtain a new access token before prompting for re-authentication. This transparent refresh maintains session continuity from the user perspective.

Protected API calls include the access token in the Authorization header using Bearer scheme. Upon receiving unauthorized responses indicating token expiration, clients attempt token refresh before retrying the original request. This pattern provides seamless token renewal without user intervention.

Logout implementation clears locally stored tokens and calls the logout endpoint to clear server-side cookies. Some applications implement automatic logout after extended inactivity periods, requiring token refresh to resume activity.

## Testing Guide

Comprehensive testing validates authentication security and functionality across various scenarios. Registration testing should verify successful account creation with valid data, appropriate error handling for invalid inputs, unique email enforcement, and verification email generation. Attempt registration with existing email addresses, invalid phone numbers, malformed NIC values, and missing required fields to confirm proper validation.

Login testing confirms successful authentication with correct credentials, appropriate error messages for incorrect passwords, account lockout after multiple failures, and token generation with expected expiration. Test login with unverified accounts, locked accounts, and non-existent email addresses to verify security controls.

Email verification requires testing valid token acceptance, expired token rejection, and malformed token handling. Attempt to verify with tokens from other users or completely fabricated tokens to ensure isolation.

Password reset testing validates token generation, email delivery, valid token acceptance, expired token rejection, and successful password update. Verify that reset tokens become invalid after use and that concurrent reset requests properly invalidate earlier tokens.

Token refresh testing confirms new token generation with valid refresh tokens, rejection of expired tokens, and rejection of manipulated tokens. Verify that access tokens generated through refresh have the expected expiration and contain correct user information.

## Production Deployment

Production deployment requires several security enhancements beyond development configuration. HTTPS becomes mandatory for all authentication endpoints, preventing credential and token interception. Configure appropriate CORS policies restricting requests to known client origins. Enable HTTP security headers through helmet middleware, including strict transport security and content security policies.

Implement comprehensive logging capturing authentication events without exposing sensitive data. Log successful logins, failed attempts, password resets, and email verification events. Integrate with monitoring systems to detect unusual patterns suggesting attacks or system compromise.

Rate limiting requires adjustment for production scale. Consider implementing progressive delays on failed attempts rather than hard cutoffs, making automation more difficult while allowing legitimate users to recover from mistakes. Deploy behind a load balancer implementing additional rate limiting at the network level.

Database connection pooling requires tuning for expected concurrent users. Configure appropriate pool sizes balancing connection overhead with availability. Implement connection retry logic with exponential backoff for resilience during brief database unavailability.

Email delivery moves from SMTP to dedicated email service providers offering better deliverability, tracking, and compliance features. Configure SPF, DKIM, and DMARC records ensuring email authentication and preventing spoofing.

## Conclusion

The AVA Insurance Authentication System provides enterprise-grade security through industry-standard implementations of proven authentication patterns. The combination of JWT-based stateless authentication, comprehensive validation, email verification, and role-based access control creates a robust foundation for the insurance platform. Future enhancements may include multi-factor authentication, social login integration, and advanced anomaly detection for identifying compromised accounts.

**Project Code:** AVA-SE-28  
**Module:** Authentication  
**Status:** Production Ready  
**Last Updated:** March 2025