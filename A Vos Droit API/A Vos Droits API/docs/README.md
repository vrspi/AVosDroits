# À Vos Droits API Documentation

## Table of Contents
1. [Authentication Endpoints](#authentication-endpoints)
2. [User Profile Endpoints](#user-profile-endpoints)
3. [Questionnaire Endpoints](#questionnaire-endpoints)
4. [Common Response Format](#common-response-format)
5. [Error Handling](#error-handling)

## Authentication Endpoints

### Register a New User
```http
POST /api/auth/register
```

**Request Body:**
```json
{
    "name": "string",
    "email": "string",
    "password": "string",
    "passwordConfirmation": "string"
}
```

**Response:**
```json
{
    "success": true,
    "data": {
        "user": {
            "id": "integer",
            "name": "string",
            "email": "string",
            "createdAt": "datetime"
        },
        "accessToken": "string"
    },
    "message": "Registration successful"
}
```

### Login
```http
POST /api/auth/login
```

**Request Body:**
```json
{
    "email": "string",
    "password": "string"
}
```

**Response:**
```json
{
    "success": true,
    "data": {
        "user": {
            "id": "integer",
            "name": "string",
            "email": "string",
            "createdAt": "datetime"
        },
        "accessToken": "string"
    },
    "message": "Login successful"
}
```

### Social Login
```http
POST /api/auth/social-login
```

**Request Body:**
```json
{
    "provider": "string",
    "accessToken": "string"
}
```

**Response:** Same as regular login

### Forgot Password
```http
POST /api/auth/forgot-password
```

**Request Body:**
```json
{
    "email": "string"
}
```

**Response:**
```json
{
    "success": true,
    "message": "Password reset link sent to email"
}
```

## User Profile Endpoints

### Get User Profile
```http
GET /api/user/profile
```

**Headers:**
- Authorization: Bearer {token}

**Response:**
```json
{
    "success": true,
    "data": {
        "user": {
            "id": "integer",
            "name": "string",
            "email": "string",
            "phone": "string",
            "address": "string",
            "createdAt": "datetime"
        }
    }
}
```

### Update User Profile
```http
PUT /api/user/profile
```

**Headers:**
- Authorization: Bearer {token}

**Request Body:**
```json
{
    "name": "string",
    "phone": "string",
    "address": "string"
}
```

**Response:**
```json
{
    "success": true,
    "data": {
        "user": {
            "id": "integer",
            "name": "string",
            "email": "string",
            "phone": "string",
            "address": "string",
            "createdAt": "datetime"
        }
    },
    "message": "Profile updated successfully"
}
```

## Questionnaire Endpoints

### Get User's Questionnaire
```http
GET /api/questionnaire
```

**Headers:**
- Authorization: Bearer {token}

**Response:**
```json
{
    "success": true,
    "data": {
        "questionnaireId": "string",
        "userId": "string",
        "completedAt": "datetime",
        "sections": [
            {
                "id": "string",
                "title": "string",
                "questions": [
                    {
                        "id": "string",
                        "question": "string",
                        "type": "string",
                        "answer": "any"
                    }
                ]
            }
        ]
    }
}
```

### Submit Questionnaire
```http
POST /api/questionnaire/submit
```

**Headers:**
- Authorization: Bearer {token}

**Request Body:**
```json
{
    "sections": [
        {
            "sectionId": "string",
            "answers": [
                {
                    "questionId": "string",
                    "answer": "any"
                }
            ]
        }
    ]
}
```

**Response:** Same format as Get Questionnaire with success message

### Update Questionnaire (Admin Only)
```http
PUT /api/questionnaire/{userId}
```

**Headers:**
- Authorization: Bearer {token}

**Request Body:** Same as Submit Questionnaire
**Response:** Same as Submit Questionnaire

## Common Response Format

All endpoints follow a standard response format:

### Success Response
```json
{
    "success": true,
    "data": {
        // Response data specific to the endpoint
    },
    "message": "string" // Optional success message
}
```

### Error Response
```json
{
    "success": false,
    "error": {
        "message": "string"
    }
}
```

## Error Handling

Common HTTP Status Codes:
- 200: Success
- 400: Bad Request (invalid input)
- 401: Unauthorized (invalid or missing token)
- 403: Forbidden (insufficient permissions)
- 404: Not Found
- 500: Internal Server Error

## Authentication

All endpoints except registration, login, and forgot password require authentication.
Include the JWT token in the Authorization header:
```
Authorization: Bearer {your_jwt_token}
```

## Rate Limiting

The API implements rate limiting to prevent abuse:
- 100 requests per minute for authenticated users
- 20 requests per minute for unauthenticated users

## Data Validation

- All email fields must be valid email addresses
- Password must be at least 6 characters long
- Names must not be empty
- Phone numbers must be in valid format
- All required fields must be provided

## Questionnaire Sections

The questionnaire is divided into 5 sections:
1. Personal Information
2. Family Status
3. Housing
4. Employment and Income
5. Social Situation

Each section has specific validation rules and required fields as per the business requirements. 