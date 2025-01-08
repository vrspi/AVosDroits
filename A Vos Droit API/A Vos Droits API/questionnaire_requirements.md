# À Vos Droits - Questionnaire Requirements

## Overview
This document outlines the questionnaire that users must complete during the registration process. The questionnaire is divided into 5 logical sections to improve user experience and data organization.

## Questionnaire Structure

### Section 1: Informations Personnelles
1. Quel est votre nom ?
   - Type: text
   - Required: true
   - Validation: non-empty string

2. Quel est votre âge ?
   - Type: number
   - Required: true
   - Validation: positive integer

3. Quelle est votre nationalité ?
   - Type: text
   - Required: true
   - Validation: non-empty string

4. Quelle est votre date de naissance ?
   - Type: date
   - Required: true
   - Format: DD/MM/YYYY
   - Validation: valid date, must be in the past

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

6. Combien d'enfants à charge avez-vous ?
   - Type: select
   - Required: true
   - Options: 0-10+
   - Default: 0

### Section 3: Logement
7. Quel est votre type de logement ?
   - Type: select
   - Required: true
   - Options:
     - Propriétaire
     - Locataire
     - Hébergé
     - Sans domicile fixe

8. Quelle est votre adresse actuelle ?
   - Type: text
   - Required: true
   - Validation: non-empty string

9. Depuis combien de temps habitez-vous à cette adresse ?
   - Type: text
   - Required: true
   - Validation: non-empty string

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

11. Dans quel secteur travaillez-vous ?
    - Type: text
    - Required: conditional (if employed or self-employed)
    - Validation: non-empty string when required

12. Quel est le type de votre contrat de travail ?
    - Type: text
    - Required: conditional (if employed)
    - Validation: non-empty string when required

13. Quel est votre revenu mensuel brut ?
    - Type: number
    - Required: conditional (if employed or self-employed)
    - Validation: positive number when required

14. Êtes-vous inscrit à Pôle Emploi ?
    - Type: boolean
    - Required: true
    - Default: false

### Section 5: Situation Sociale
15. Avez-vous des problèmes de santé qui nécessitent une assistance spécifique ?
    - Type: boolean
    - Required: true
    - Default: false

16. Êtes-vous en situation de handicap ?
    - Type: boolean
    - Required: true
    - Default: false

17. Avez-vous un statut d'immigrant ou de réfugié ?
    - Type: boolean
    - Required: true
    - Default: false

18. Recevez-vous actuellement des allocations ou aides sociales ?
    - Type: boolean
    - Required: true
    - Default: false

19. Avez-vous des dettes ou des crédits en cours ?
    - Type: boolean
    - Required: true
    - Default: false

20. Êtes-vous bénéficiaire de l'aide au logement (APL) ?
    - Type: boolean
    - Required: true
    - Default: false

21. Avez-vous déjà fait une demande d'allocations familiales ?
    - Type: boolean
    - Required: true
    - Default: false

22. Avez-vous d'autres sources de revenus ?
    - Type: boolean
    - Required: true
    - Default: false

## Technical Requirements

### API Endpoints
1. Create a new questionnaire response:
   ```
   POST /api/questionnaire/submit
   ```

2. Update an existing questionnaire response:
   ```
   PUT /api/questionnaire/{user_id}
   ```

3. Get user's questionnaire responses:
   ```
   GET /api/questionnaire/{user_id}
   ```

### Data Storage
- All responses should be stored securely in the database
- Each response should be linked to the user's account
- Maintain version history of responses
- Implement data encryption for sensitive information

### Validation Rules
- Implement server-side validation for all fields
- Validate date formats and ranges
- Ensure conditional fields are properly handled
- Sanitize all text inputs

### Response Format
```json
{
    "success": true,
    "data": {
        "questionnaire_id": "string",
        "user_id": "string",
        "completed_at": "timestamp",
        "sections": [
            {
                "id": "string",
                "title": "string",
                "questions": [
                    {
                        "id": "string",
                        "question": "string",
                        "answer": "any",
                        "type": "string"
                    }
                ]
            }
        ]
    }
}
```

### Security Considerations
1. Implement rate limiting
2. Validate user authentication
3. Implement proper error handling
4. Log all questionnaire submissions
5. Implement GDPR compliance measures
6. Regular security audits

## Integration Requirements
- The questionnaire should be completed after user registration
- Responses should be used to personalize user experience
- Data should be accessible for rights recommendations
- Implement analytics to track completion rates
- Enable data export functionality for authorized personnel 