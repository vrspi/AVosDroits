-- Clear existing data
DELETE FROM QuestionOptions;
DELETE FROM QuestionnaireQuestions;

-- Personal Information Section
INSERT INTO QuestionnaireQuestions (Id, SectionId, Question, Type, Required, [Order], ValidationRules)
VALUES 
('name', 'personal_info', 'Nom complet', 'text', 1, 1, NULL),
('age', 'personal_info', 'Âge', 'number', 1, 2, '{"min": 0, "max": 150}'),
('nationality', 'personal_info', 'Nationalité', 'text', 1, 3, NULL),
('birth_date', 'personal_info', 'Date de naissance', 'date', 1, 4, NULL);

-- Family Status Section
INSERT INTO QuestionnaireQuestions (Id, SectionId, Question, Type, Required, [Order], ValidationRules)
VALUES 
('marital_status', 'family_status', 'Situation familiale', 'select', 1, 1, NULL),
('dependents', 'family_status', 'Nombre d''enfants à charge', 'select', 1, 2, NULL);

-- Housing Section
INSERT INTO QuestionnaireQuestions (Id, SectionId, Question, Type, Required, [Order], ValidationRules)
VALUES 
('housing_type', 'housing', 'Type de logement', 'select', 1, 1, NULL),
('current_address', 'housing', 'Adresse actuelle', 'text', 1, 2, NULL),
('residence_duration', 'housing', 'Durée d''habitation', 'text', 1, 3, NULL);

-- Employment Section
INSERT INTO QuestionnaireQuestions (Id, SectionId, Question, Type, Required, [Order], ValidationRules)
VALUES 
('employment_status', 'employment', 'Statut d''emploi', 'select', 1, 1, NULL),
('sector', 'employment', 'Secteur d''activité', 'text', 0, 2, NULL),
('contract_type', 'employment', 'Type de contrat', 'text', 0, 3, NULL),
('monthly_income', 'employment', 'Revenu mensuel brut', 'number', 0, 4, '{"min": 0}'),
('job_seeker', 'employment', 'Inscrit à Pôle Emploi', 'boolean', 1, 5, NULL);

-- Social Benefits Section
INSERT INTO QuestionnaireQuestions (Id, SectionId, Question, Type, Required, [Order], ValidationRules)
VALUES 
('health_issues', 'social_situation', 'Problèmes de santé nécessitant une assistance', 'boolean', 1, 1, NULL),
('disability', 'social_situation', 'En situation de handicap', 'boolean', 1, 2, NULL),
('immigrant_status', 'social_situation', 'Statut d''immigrant ou réfugié', 'boolean', 1, 3, NULL),
('social_benefits', 'social_situation', 'Bénéficiaire d''allocations ou aides sociales', 'boolean', 1, 4, NULL),
('debts', 'social_situation', 'Dettes ou crédits en cours', 'boolean', 1, 5, NULL),
('housing_assistance', 'social_situation', 'Bénéficiaire de l''aide au logement (APL)', 'boolean', 1, 6, NULL),
('family_allowance', 'social_situation', 'Demande d''allocations familiales effectuée', 'boolean', 1, 7, NULL),
('other_income', 'social_situation', 'Autres sources de revenus', 'boolean', 1, 8, NULL);

-- Insert Options for Marital Status
INSERT INTO QuestionOptions (QuestionId, Value, Label, [Order])
VALUES 
('marital_status', 'single', 'Célibataire', 1),
('marital_status', 'married', 'Marié(e)', 2),
('marital_status', 'pacs', 'Pacsé(e)', 3),
('marital_status', 'divorced', 'Divorcé(e)', 4),
('marital_status', 'widowed', 'Veuf/Veuve', 5);

-- Insert Options for Housing Type
INSERT INTO QuestionOptions (QuestionId, Value, Label, [Order])
VALUES 
('housing_type', 'owner', 'Propriétaire', 1),
('housing_type', 'tenant', 'Locataire', 2),
('housing_type', 'hosted', 'Hébergé', 3),
('housing_type', 'homeless', 'Sans domicile fixe', 4);

-- Insert Options for Employment Status
INSERT INTO QuestionOptions (QuestionId, Value, Label, [Order])
VALUES 
('employment_status', 'employed', 'Employé(e)', 1),
('employment_status', 'self_employed', 'Indépendant(e)', 2),
('employment_status', 'unemployed', 'Sans emploi', 3),
('employment_status', 'student', 'Étudiant(e)', 4),
('employment_status', 'retired', 'Retraité(e)', 5);

-- Insert Options for Number of Dependents (0-10)
INSERT INTO QuestionOptions (QuestionId, Value, Label, [Order])
VALUES 
('dependents', '0', '0', 1),
('dependents', '1', '1', 2),
('dependents', '2', '2', 3),
('dependents', '3', '3', 4),
('dependents', '4', '4', 5),
('dependents', '5', '5', 6),
('dependents', '6', '6', 7),
('dependents', '7', '7', 8),
('dependents', '8', '8', 9),
('dependents', '9', '9', 10),
('dependents', '10', '10+', 11); 