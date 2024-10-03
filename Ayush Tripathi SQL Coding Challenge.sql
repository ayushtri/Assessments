CREATE DATABASE VirtualArtGallery;
GO

EXEC sp_databases;
GO

USE VirtualArtGallery;
GO

--DDL

-- Create the Artists table
CREATE TABLE Artists (
ArtistID INT PRIMARY KEY,
Name VARCHAR(255) NOT NULL,
Biography TEXT,
Nationality VARCHAR(100));


-- Create the Categories table
CREATE TABLE Categories (
CategoryID INT PRIMARY KEY,
Name VARCHAR(100) NOT NULL);


-- Create the Artworks table
CREATE TABLE Artworks (
ArtworkID INT PRIMARY KEY,
Title VARCHAR(255) NOT NULL,
ArtistID INT,
CategoryID INT,
Year INT,
Description TEXT,
ImageURL VARCHAR(255),
FOREIGN KEY (ArtistID) REFERENCES Artists (ArtistID),
FOREIGN KEY (CategoryID) REFERENCES Categories (CategoryID));


-- Create the Exhibitions table
CREATE TABLE Exhibitions (
ExhibitionID INT PRIMARY KEY,
Title VARCHAR(255) NOT NULL,
StartDate DATE,
EndDate DATE,
Description TEXT);


-- Create a table to associate artworks with exhibitions
CREATE TABLE ExhibitionArtworks (
ExhibitionID INT,
ArtworkID INT,
PRIMARY KEY (ExhibitionID, ArtworkID),
FOREIGN KEY (ExhibitionID) REFERENCES Exhibitions (ExhibitionID),
FOREIGN KEY (ArtworkID) REFERENCES Artworks (ArtworkID));

--DML

-- Insert sample data into the Artists table
INSERT INTO Artists (ArtistID, Name, Biography, Nationality) VALUES
(1, 'Pablo Picasso', 'Renowned Spanish painter and sculptor.', 'Spanish'),
(2, 'Vincent van Gogh', 'Dutch post-impressionist painter.', 'Dutch'),
(3, 'Leonardo da Vinci', 'Italian polymath of the Renaissance.', 'Italian');


-- Insert sample data into the Categories table
INSERT INTO Categories (CategoryID, Name) VALUES
(1, 'Painting'),
(2, 'Sculpture'),
(3, 'Photography');


-- Insert sample data into the Artworks table
INSERT INTO Artworks (ArtworkID, Title, ArtistID, CategoryID, Year, Description, ImageURL) VALUES
(1, 'Starry Night', 2, 1, 1889, 'A famous painting by Vincent van Gogh.', 'starry_night.jpg'),
(2, 'Mona Lisa', 3, 1, 1503, 'The iconic portrait by Leonardo da Vinci.', 'mona_lisa.jpg'),
(3, 'Guernica', 1, 1, 1937, 'Pablo Picasso''s powerful anti-war mural.', 'guernica.jpg');


-- Insert sample data into the Exhibitions table
INSERT INTO Exhibitions (ExhibitionID, Title, StartDate, EndDate, Description) VALUES
(1, 'Modern Art Masterpieces', '2023-01-01', '2023-03-01', 'A collection of modern art masterpieces.'),
(2, 'Renaissance Art', '2023-04-01', '2023-06-01', 'A showcase of Renaissance art treasures.');


-- Insert artworks into exhibitions
INSERT INTO ExhibitionArtworks (ExhibitionID, ArtworkID) VALUES
(1, 1),
(1, 2),
(1, 3),
(2, 2);

-- Queries

-- 1. Retrieve the names of all artists along with the number of artworks they have in the gallery, and list them in descending order of the number of artworks.
SELECT a.Name, COUNT(aw.ArtworkID) NoOfArtworks
FROM Artists a
JOIN Artworks aw
ON a.ArtistID = aw.ArtistID
GROUP BY a.Name
ORDER BY COUNT(aw.ArtworkID) DESC;


-- 2. List the titles of artworks created by artists from 'Spanish' and 'Dutch' nationalities, and order them by the year in ascending order.
SELECT aw.Title, aw.Year
FROM Artists a
JOIN Artworks aw
ON a.ArtistID = aw.ArtistID
WHERE a.Nationality IN ('Spanish','Dutch')
ORDER BY aw.Year;


-- 3. Find the names of all artists who have artworks in the 'Painting' category, and the number of artworks they have in this category. 
SELECT a.Name, COUNT(aw.ArtistID) NoOfArtworks
FROM Artists a
JOIN Artworks aw
ON a.ArtistID = aw.ArtistID
JOIN Categories c
ON c.CategoryID = aw.CategoryID
WHERE c.Name = 'Painting'
GROUP BY a.Name;


-- 4. List the names of artworks from the 'Modern Art Masterpieces' exhibition, along with their artists and categories.
SELECT aw.Title, a.Name, c.Name
FROM ExhibitionArtworks ea
JOIN Exhibitions e
ON ea.ExhibitionID = e.ExhibitionID
JOIN Artworks aw
ON aw.ArtworkID = ea.ArtworkID
JOIN Artists a
ON aw.ArtworkID = a.ArtistID
JOIN Categories c
ON c.CategoryID = aw.CategoryID
WHERE e.Title = 'Modern Art Masterpieces';


-- 5. Find the artists who have more than two artworks in the gallery.
SELECT a.Name
FROM Artists a
JOIN Artworks aw
ON a.ArtistID = aw.ArtistID
GROUP BY a.Name
HAVING COUNT(aw.ArtworkID) > 2;


-- 6. Find the titles of artworks that were exhibited in both 'Modern Art Masterpieces' and 'Renaissance Art' exhibitions
SELECT aw.Title
FROM Artworks aw
WHERE aw.ArtworkID IN (
	SELECT ea.ArtworkID
	FROM ExhibitionArtworks ea
	JOIN Exhibitions e
	ON e.ExhibitionID = ea.ExhibitionID
	WHERE e.Title = 'Modern Art Masterpieces'
)
AND aw.ArtworkID IN (
	SELECT ea.ArtworkID
	FROM ExhibitionArtworks ea
	JOIN Exhibitions e
	ON e.ExhibitionID = ea.ExhibitionID
	WHERE e.Title = 'Renaissance Art'
);

-- 7. Find the total number of artworks in each category
SELECT c.Name , COUNT(aw.ArtworkID) AS NoOfArtworks
FROM Categories c
LEFT JOIN Artworks aw 
ON c.CategoryID = aw.CategoryID
GROUP BY c.CategoryID, c.Name;


-- 8. List artists who have more than 3 artworks in the gallery.
SELECT a.Name
FROM Artists a
JOIN Artworks aw
ON a.ArtistID = aw.ArtistID
GROUP BY a.Name
HAVING COUNT(aw.ArtworkID) > 3;


-- 9. Find the artworks created by artists from a specific nationality (e.g., Spanish).
SELECT aw.Title
FROM Artworks aw
JOIN Artists a
ON a.ArtistID = aw.ArtistID
WHERE a.Nationality = 'Spanish';


-- 10. List exhibitions that feature artwork by both Vincent van Gogh and Leonardo da Vinci.
SELECT e.Title
FROM Exhibitions e
WHERE e.ExhibitionID IN (
    SELECT ea.ExhibitionID
    FROM ExhibitionArtworks ea
    JOIN Artworks aw
	ON ea.ArtworkID = aw.ArtworkID
    JOIN Artists a 
	ON aw.ArtistID = a.ArtistID
    WHERE a.Name = 'Vincent van Gogh'
)
AND e.ExhibitionID IN (
    SELECT ea.ExhibitionID
    FROM ExhibitionArtworks ea
    JOIN Artworks aw
	ON ea.ArtworkID = aw.ArtworkID
    JOIN Artists a
	ON aw.ArtistID = a.ArtistID
    WHERE a.Name = 'Leonardo da Vinci'
);


-- 11. Find all the artworks that have not been included in any exhibition.
SELECT aw.Title
FROM Artworks aw
LEFT JOIN ExhibitionArtworks ea
ON aw.ArtworkID	 = ea.ArtworkID
WHERE ea.ExhibitionID IS NULL;


-- 12. List artists who have created artworks in all available categories.
SELECT a.Name
FROM Artists a
JOIN Artworks aw
ON a.ArtistID = aw.ArtistID
JOIN Categories c
ON c.CategoryID = aw.CategoryID
GROUP BY a.Name
HAVING COUNT(DISTINCT c.Name) = (SELECT COUNT(*) FROM Categories);

-- 13. List the total number of artworks in each category.
SELECT c.Name , COUNT(aw.ArtworkID) NoOfArtworks
FROM Categories c
LEFT JOIN Artworks aw 
ON c.CategoryID = aw.CategoryID
GROUP BY c.CategoryID, c.Name;


-- 14. Find the artists who have more than 2 artworks in the gallery.
SELECT a.Name
FROM Artists a
JOIN Artworks aw
ON a.ArtistID = aw.ArtistID
GROUP BY a.Name
HAVING COUNT(aw.ArtworkID) > 2;


-- 15. List the categories with the average year of artworks they contain, only for categories with more than 1 artwork.
SELECT c.Name, AVG(aw.Year) AvgYear
FROM Categories c
JOIN Artworks aw
ON c.CategoryID = aw.CategoryID
GROUP BY c.Name
HAVING COUNT(aw.ArtworkID) > 1;


-- 16. Find the artworks that were exhibited in the 'Modern Art Masterpieces' exhibition.
SELECT aw.Title
FROM Artworks aw
JOIN ExhibitionArtworks ea
ON ea.ArtworkID = aw.ArtworkID
JOIN Exhibitions e
ON e.ExhibitionID = ea.ExhibitionID
WHERE e.Title = 'Modern Art Masterpieces';


-- 17. Find the categories where the average year of artworks is greater than the average year of all artworks.
SELECT c.NAME, AVG(aw.Year) AvgYear
FROM Categories c
JOIN Artworks aw
ON c.CategoryID = aw.CategoryID
GROUP BY c.Name
HAVING AVG(aw.Year) > (SELECT AVG(Year) FROM Artworks);

-- 18. List the artworks that were not exhibited in any exhibition.
SELECT aw.Title
FROM Artworks aw
LEFT JOIN ExhibitionArtworks ea
ON aw.ArtworkID	 = ea.ArtworkID
WHERE ea.ExhibitionID IS NULL;


-- 19. Show artists who have artworks in the same category as "Mona Lisa."
SELECT a.Name
FROM Artists a
JOIN Artworks aw
ON a.ArtistID = aw.ArtistID
WHERE aw.CategoryID = (
	SELECT aw.CategoryID
	FROM Artworks aw
	WHERE aw.Title = 'Mona Lisa'
);


-- 20. List the names of artists and the number of artworks they have in the gallery.
SELECT a.Name, COUNT(aw.ArtworkID) NoOfArtworks
FROM Artists a
JOIN Artworks aw
ON a.ArtistID = aw.ArtistID
GROUP BY a.Name;