# À Vos Droits - Backend API Documentation

## Authentication APIs

### 1. User Registration
**Endpoint:** `POST /api/auth/register`
```json
Request:
{
    "name": "string",
    "email": "string",
    "password": "string",
    "password_confirmation": "string"
}

Response:
{
    "success": true,
    "data": {
        "user": {
            "id": "integer",
            "name": "string",
            "email": "string",
            "created_at": "timestamp"
        },
        "access_token": "string"
    },
    "message": "Registration successful"
}
```

### 2. User Login
**Endpoint:** `POST /api/auth/login`
```json
Request:
{
    "email": "string",
    "password": "string"
}

Response:
{
    "success": true,
    "data": {
        "user": {
            "id": "integer",
            "name": "string",
            "email": "string",
            "created_at": "timestamp"
        },
        "access_token": "string"
    },
    "message": "Login successful"
}
```

### 3. Social Authentication
**Endpoint:** `POST /api/auth/social-login`
```json
Request:
{
    "provider": "string", // "google" or "facebook"
    "access_token": "string"
}

Response:
{
    "success": true,
    "data": {
        "user": {
            "id": "integer",
            "name": "string",
            "email": "string",
            "created_at": "timestamp"
        },
        "access_token": "string"
    },
    "message": "Social login successful"
}
```

### 4. Password Reset
**Endpoint:** `POST /api/auth/forgot-password`
```json
Request:
{
    "email": "string"
}

Response:
{
    "success": true,
    "message": "Password reset link sent to email"
}
```

## User Profile APIs

### 1. Get User Profile
**Endpoint:** `GET /api/user/profile`
```json
Response:
{
    "success": true,
    "data": {
        "user": {
            "id": "integer",
            "name": "string",
            "email": "string",
            "phone": "string?",
            "address": "string?",
            "created_at": "timestamp"
        }
    }
}
```

### 2. Update User Profile
**Endpoint:** `PUT /api/user/profile`
```json
Request:
{
    "name": "string?",
    "phone": "string?",
    "address": "string?"
}

Response:
{
    "success": true,
    "data": {
        "user": {
            "id": "integer",
            "name": "string",
            "email": "string",
            "phone": "string?",
            "address": "string?",
            "updated_at": "timestamp"
        }
    },
    "message": "Profile updated successfully"
}
```

## Rights Database APIs

### 1. Get Rights Categories
**Endpoint:** `GET /api/rights/categories`
```json
Response:
{
    "success": true,
    "data": {
        "categories": [
            {
                "id": "integer",
                "name": "string",
                "description": "string",
                "icon": "string"
            }
        ]
    }
}
```

### 2. Get Rights by Category
**Endpoint:** `GET /api/rights/category/{category_id}`
```json
Response:
{
    "success": true,
    "data": {
        "rights": [
            {
                "id": "integer",
                "title": "string",
                "description": "string",
                "category_id": "integer",
                "content": "text",
                "references": "array"
            }
        ]
    }
}
```

### 3. Search Rights
**Endpoint:** `GET /api/rights/search`
```json
Request Query Parameters:
{
    "q": "string", // search query
    "category": "integer?" // optional category filter
}

Response:
{
    "success": true,
    "data": {
        "rights": [
            {
                "id": "integer",
                "title": "string",
                "description": "string",
                "category_id": "integer",
                "content": "text",
                "references": "array"
            }
        ]
    }
}
```

## Questionnaire APIs

### 1. Get Questionnaire
**Endpoint:** `GET /api/questionnaire/{category_id}`
```json
Response:
{
    "success": true,
    "data": {
        "questionnaire": {
            "id": "integer",
            "title": "string",
            "description": "string",
            "questions": [
                {
                    "id": "integer",
                    "question": "string",
                    "type": "string", // "multiple_choice", "yes_no", "text"
                    "options": "array?" // for multiple choice questions
                }
            ]
        }
    }
}
```

### 2. Submit Questionnaire
**Endpoint:** `POST /api/questionnaire/submit`
```json
Request:
{
    "questionnaire_id": "integer",
    "answers": [
        {
            "question_id": "integer",
            "answer": "string"
        }
    ]
}

Response:
{
    "success": true,
    "data": {
        "result": {
            "rights": [
                {
                    "id": "integer",
                    "title": "string",
                    "description": "string",
                    "content": "text",
                    "relevance_score": "float"
                }
            ],
            "recommendations": "array"
        }
    }
}
```

## Document Generation APIs

### 1. Generate Letter
**Endpoint:** `POST /api/documents/generate-letter`
```json
Request:
{
    "template_id": "integer",
    "data": {
        "recipient": {
            "name": "string",
            "address": "string"
        },
        "content": {
            "subject": "string",
            "body": "string"
        },
        "user_details": {
            "name": "string",
            "address": "string"
        }
    }
}

Response:
{
    "success": true,
    "data": {
        "document": {
            "id": "integer",
            "file_url": "string",
            "created_at": "timestamp"
        }
    }
}
```

### 2. Get Letter Templates
**Endpoint:** `GET /api/documents/templates`
```json
Response:
{
    "success": true,
    "data": {
        "templates": [
            {
                "id": "integer",
                "name": "string",
                "description": "string",
                "category": "string",
                "required_fields": "array"
            }
        ]
    }
}
```

## Local Services APIs

### 1. Search Services
**Endpoint:** `GET /api/services/search`
```json
Request Query Parameters:
{
    "latitude": "float",
    "longitude": "float",
    "radius": "integer", // in kilometers
    "category": "string?" // optional service category
}

Response:
{
    "success": true,
    "data": {
        "services": [
            {
                "id": "integer",
                "name": "string",
                "description": "string",
                "address": "string",
                "latitude": "float",
                "longitude": "float",
                "phone": "string",
                "email": "string",
                "website": "string?",
                "hours": "object",
                "distance": "float" // in kilometers
            }
        ]
    }
}
```

## Expert Consultation APIs

### 1. Get Available Experts
**Endpoint:** `GET /api/experts`
```json
Request Query Parameters:
{
    "speciality": "string?",
    "language": "string?",
    "date": "date?"
}

Response:
{
    "success": true,
    "data": {
        "experts": [
            {
                "id": "integer",
                "name": "string",
                "speciality": "string",
                "languages": "array",
                "rating": "float",
                "hourly_rate": "float",
                "available_slots": [
                    {
                        "date": "date",
                        "times": "array"
                    }
                ]
            }
        ]
    }
}
```

### 2. Book Consultation
**Endpoint:** `POST /api/consultations/book`
```json
Request:
{
    "expert_id": "integer",
    "date": "date",
    "time": "string",
    "consultation_type": "string", // "video", "audio", "chat"
    "notes": "string?"
}

Response:
{
    "success": true,
    "data": {
        "consultation": {
            "id": "integer",
            "expert": "object",
            "date": "date",
            "time": "string",
            "type": "string",
            "status": "string",
            "meeting_link": "string?"
        }
    },
    "message": "Consultation booked successfully"
}
```

## Digital Safe APIs

### 1. Upload Document
**Endpoint:** `POST /api/safe/documents`
```json
Request:
{
    "file": "file",
    "name": "string",
    "category": "string",
    "tags": "array?"
}

Response:
{
    "success": true,
    "data": {
        "document": {
            "id": "integer",
            "name": "string",
            "category": "string",
            "tags": "array",
            "size": "integer",
            "created_at": "timestamp"
        }
    }
}
```

### 2. Get Documents
**Endpoint:** `GET /api/safe/documents`
```json
Request Query Parameters:
{
    "category": "string?",
    "tags": "array?",
    "search": "string?"
}

Response:
{
    "success": true,
    "data": {
        "documents": [
            {
                "id": "integer",
                "name": "string",
                "category": "string",
                "tags": "array",
                "size": "integer",
                "created_at": "timestamp"
            }
        ]
    }
}
```

## General Requirements

### Authentication
- All endpoints except authentication endpoints require a valid JWT token in the Authorization header
- Token format: `Bearer {token}`

### Error Responses
```json
{
    "success": false,
    "error": {
        "code": "string",
        "message": "string",
        "details": "object?"
    }
}
```

### Pagination
For endpoints returning lists, use the following query parameters:
- `page`: integer (default: 1)
- `per_page`: integer (default: 20)

Response will include:
```json
{
    "success": true,
    "data": {
        "items": [],
        "pagination": {
            "current_page": "integer",
            "per_page": "integer",
            "total_pages": "integer",
            "total_items": "integer"
        }
    }
}
```

### Security Requirements
1. Implement rate limiting
2. Use HTTPS for all endpoints
3. Implement input validation
4. Sanitize all user inputs
5. Implement proper error handling
6. Log all API access and errors
7. Implement file upload restrictions
8. Use prepared statements for database queries
9. Implement CORS policies
10. Regular security audits 