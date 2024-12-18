# À Vos Droits - Questionnaire Requirements

## Overview
This document outlines the questionnaire that users must complete during the registration process. The questionnaire is divided into 5 logical sections to improve user experience and data organization.

## API Integration

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

### Update Questionnaire (Admin Only)
```http
PUT /api/questionnaire/{userId}
```

**Headers:**
- Authorization: Bearer {token}

## Questionnaire Structure

### Section 1: Informations Personnelles
1. Quel est votre nom ?
   - Type: text
   - Required: true
   - Validation: non-empty string
   - QuestionId: "personal_name"

2. Quel est votre âge ?
   - Type: number
   - Required: true
   - Validation: positive integer
   - QuestionId: "personal_age"

3. Quelle est votre nationalité ?
   - Type: text
   - Required: true
   - Validation: non-empty string
   - QuestionId: "personal_nationality"

4. Quelle est votre date de naissance ?
   - Type: date
   - Required: true
   - Format: DD/MM/YYYY
   - Validation: valid date, must be in the past
   - QuestionId: "personal_birthdate"

### Section 2: Situation Familiale
5. Quelle est votre situation familiale ?
   - Type: select
   - Required: true
   - Options:
     - Célibataire
     - Marié(e)
     - Pacsé(e)
     - Divorcé(e)
     - Veuf/Veuve
   - QuestionId: "family_status"

6. Combien d'enfants à charge avez-vous ?
   - Type: select
   - Required: true
   - Options: 0-10+
   - Default: 0
   - QuestionId: "family_children"

### Section 3: Logement
7. Quel est votre type de logement ?
   - Type: select
   - Required: true
   - Options:
     - Propriétaire
     - Locataire
     - Hébergé
     - Sans domicile fixe
   - QuestionId: "housing_type"

8. Quelle est votre adresse actuelle ?
   - Type: text
   - Required: true
   - Validation: non-empty string
   - QuestionId: "housing_address"

9. Depuis combien de temps habitez-vous à cette adresse ?
   - Type: text
   - Required: true
   - Validation: non-empty string
   - QuestionId: "housing_duration"

### Section 4: Emploi et Revenus
10. Quel est votre statut d'emploi ?
    - Type: select
    - Required: true
    - Options:
      - Employé(e)
      - Indépendant(e)
      - Sans emploi
      - Étudiant(e)
      - Retraité(e)
    - QuestionId: "employment_status"

11. Dans quel secteur travaillez-vous ?
    - Type: text
    - Required: conditional (if employed or self-employed)
    - Validation: non-empty string when required
    - QuestionId: "employment_sector"

12. Quel est le type de votre contrat de travail ?
    - Type: text
    - Required: conditional (if employed)
    - Validation: non-empty string when required
    - QuestionId: "employment_contract"

13. Quel est votre revenu mensuel brut ?
    - Type: number
    - Required: conditional (if employed or self-employed)
    - Validation: positive number when required
    - QuestionId: "employment_income"

14. Êtes-vous inscrit à Pôle Emploi ?
    - Type: boolean
    - Required: true
    - Default: false
    - QuestionId: "employment_pole_emploi"

### Section 5: Situation Sociale
15. Avez-vous des problèmes de santé qui nécessitent une assistance spécifique ?
    - Type: boolean
    - Required: true
    - Default: false
    - QuestionId: "social_health_issues"

16. Êtes-vous en situation de handicap ?
    - Type: boolean
    - Required: true
    - Default: false
    - QuestionId: "social_disability"

17. Avez-vous un statut d'immigrant ou de réfugié ?
    - Type: boolean
    - Required: true
    - Default: false
    - QuestionId: "social_immigrant"

18. Recevez-vous actuellement des allocations ou aides sociales ?
    - Type: boolean
    - Required: true
    - Default: false
    - QuestionId: "social_benefits"

19. Avez-vous des dettes ou des crédits en cours ?
    - Type: boolean
    - Required: true
    - Default: false
    - QuestionId: "social_debts"

20. Êtes-vous bénéficiaire de l'aide au logement (APL) ?
    - Type: boolean
    - Required: true
    - Default: false
    - QuestionId: "social_housing_aid"

21. Avez-vous déjà fait une demande d'allocations familiales ?
    - Type: boolean
    - Required: true
    - Default: false
    - QuestionId: "social_family_allowance"

22. Avez-vous d'autres sources de revenus ?
    - Type: boolean
    - Required: true
    - Default: false
    - QuestionId: "social_other_income"

## Example Request Body
```json
{
    "sections": [
        {
            "sectionId": "personal_info",
            "answers": [
                {
                    "questionId": "personal_name",
                    "answer": "John Doe"
                },
                {
                    "questionId": "personal_age",
                    "answer": 30
                },
                {
                    "questionId": "personal_nationality",
                    "answer": "French"
                },
                {
                    "questionId": "personal_birthdate",
                    "answer": "15/05/1993"
                }
            ]
        },
        {
            "sectionId": "family_status",
            "answers": [
                {
                    "questionId": "family_status",
                    "answer": "Marié(e)"
                },
                {
                    "questionId": "family_children",
                    "answer": 2
                }
            ]
        }
        // ... other sections
    ]
}
```

## Technical Requirements

### Authentication
- All endpoints require a valid JWT token in the Authorization header
- Token format: `Bearer {token}`

### Error Handling
Common HTTP Status Codes:
- 200: Success
- 400: Bad Request (invalid input)
- 401: Unauthorized (invalid or missing token)
- 403: Forbidden (insufficient permissions)
- 404: Not Found
- 500: Internal Server Error

### Error Response Format
```json
{
    "success": false,
    "error": {
        "message": "string"
    }
}
```

### Rate Limiting
- 100 requests per minute for authenticated users
- 20 requests per minute for unauthenticated users

### Data Validation
- All required fields must be provided
- Conditional fields must be validated based on dependencies
- Date formats must be DD/MM/YYYY
- Numbers must be positive where applicable
- Text fields must be non-empty where required

### Security Requirements
1. Implement rate limiting
2. Validate user authentication
3. Implement proper error handling
4. Log all questionnaire submissions
5. Implement GDPR compliance measures
6. Regular security audits

### Integration Requirements
- The questionnaire should be completed after user registration
- Responses should be used to personalize user experience
- Data should be accessible for rights recommendations
- Implement analytics to track completion rates
- Enable data export functionality for authorized personnel