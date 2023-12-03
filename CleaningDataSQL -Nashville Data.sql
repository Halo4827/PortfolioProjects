/*

Cleaning Data om SQL Queries

*/


SELECT * FROM Project4..Nashville

--------------------------------------------------------------------------------------

--Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM Project4..Nashville

Update Project4..Nashville
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE Project4..Nashville
ADD SaleDateConverted Date;

UPDATE Project4..Nashville
SET SaleDateConverted = CONVERT(DATE, SaleDate)

---------------------------------------------------------------------------------------

--Populate Property Address data

SELECT PropertyAddress
FROM Project4..Nashville
WHERE PropertyAddress is null

SELECT * 
FROM Project4..Nashville
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM Project4..Nashville a
JOIN Project4..Nashville b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Project4..Nashville a
JOIN Project4..Nashville b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

--------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City) - PropertyAddress

SELECT PropertyAddress
FROM Project4..Nashville

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM Project4..Nashville

ALTER TABLE NProject4..Nashville
ADD PropertySplitAddress nvarchar(255);

UPDATE Project4..Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Project4..Nashville
ADD PropertySplitCity nvarchar(255);

UPDATE Project4..Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 

SELECT *
FROM Project4..Nashville


--Breaking out Address into Individual Columns (Address, City, State) - OwnerAddress

SELECT OwnerAddress
FROM Project4..Nashville

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3) AS Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2) AS City,
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1) AS State
FROM Project4..Nashville

ALTER TABLE Project4..Nashville
ADD OwnerSplitAddress nvarchar(255);

UPDATE Project4..Nashville
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE Project4..Nashville
ADD OwnerSplitCity nvarchar(255);

UPDATE Project4..Nashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2) 

ALTER TABLE Project4..Nashville
ADD OwnerSplitState nvarchar(255);

UPDATE Project4..Nashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1  ) 

SELECT *
FROM Project4..Nashville

----------------------------------------------------------------------------------------------------

--Change Y and Y to Yes and No in "Sold as Vacant" field

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS VacantCount
FROM Project4..Nashville
GROUP BY SoldAsVacant
ORDER BY 2

Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM Project4..Nashville


UPDATE Project4..Nashville
SET SoldAsVacant = CASE 
	 WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS VacantCount
FROM Project4..Nashville
GROUP BY SoldAsVacant
ORDER BY 2

-----------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM Project4..Nashville
)

DELETE
FROM RowNumCTE
WHERE row_num > 1



-----------------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns

SELECT *
FROM Project4..Nashville

ALTER TABLE Project4..Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Project4..Nashville
DROP COLUMN SaleDate