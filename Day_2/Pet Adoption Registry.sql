CREATE DATABASE pet_registry;

USE pet_registry;

-- Table: pets: pet_id, name, species, breed, age, adopted, owner_name
CREATE TABLE pets (
    pet_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    species VARCHAR(50),
    breed VARCHAR(100),
    age INT,
    adopted BOOLEAN,
    owner_name VARCHAR(100)
);

INSERT INTO pets (name, species, breed, age, adopted, owner_name) VALUES
('Bella', 'Dog', 'German Shepherd', 3, TRUE, 'Anita Desai'),
('Max', 'Dog', 'Australian Shepherd', 2, FALSE, NULL),
('Milo', 'Cat', 'Siamese', 4, FALSE, NULL),
('Luna', 'Dog', 'Labrador Retriever', 1, TRUE, 'Ravi Mehra'),
('Rocky', 'Dog', 'Belgian Shepherd', 5, FALSE, NULL),
('Simba', 'Cat', 'Persian', 6, TRUE, 'Kavita Shah'),
('Oscar', 'Rabbit', 'Mini Rex', 2, FALSE, NULL);

-- Retrieve pets not yet adopted.
SELECT pet_id, name, species, breed, age, owner_name
FROM pets
WHERE adopted = FALSE;

-- Use BETWEEN for age (1–5 years).
SELECT pet_id, name, species, breed, age, owner_name
FROM pets
WHERE age BETWEEN 1 AND 5;

-- Use LIKE to find breed containing “shepherd”.
SELECT pet_id, name, species, breed, age, adopted
FROM pets
WHERE breed LIKE '%shepherd%';

-- Show name, breed, and species.
SELECT name, breed, species
FROM pets;

-- Identify pets with NULL owner.
SELECT pet_id, name, species, breed, age
FROM pets
WHERE owner_name IS NULL;


-- Use DISTINCT for species.
SELECT DISTINCT species
FROM pets;

-- Sort by age ASC, name ASC.
SELECT pet_id, name, species, breed, age, adopted, owner_name
FROM pets
ORDER BY age ASC, name ASC;
