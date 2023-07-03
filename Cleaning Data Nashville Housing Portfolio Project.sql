/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM PortfolioProject..NashvilleHousing

----------------------------------------------------------------------------------------------------------------
 --Standardize sale date

 SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)

----------------------------------------------------------------------------------------------------------------

-- Populate Property Addresss Data
 SELECT *
FROM PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

 SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

----------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

 SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))



SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress,',' , '.'),3),
PARSENAME(REPLACE(OwnerAddress,',' , '.'),2),
PARSENAME(REPLACE(OwnerAddress,',' , '.'),1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',' , '.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',' , '.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',' , '.'),1)

SELECT *
FROM PortfolioProject..NashvilleHousing

----------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" Field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
Group By SoldAsVacant
Order by 2


SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   When SoldAsVacant = ' No' Then 'No'
	   Else SoldAsVacant
	   END
FROM PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   When SoldAsVacant = ' No' Then 'No'
	   Else SoldAsVacant
	   END

----------------------------------------------------------------------------------------------------------------

--Remove Duplicates
WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM PortfolioProject..NashvilleHousing
--Order By ParcelID
)
Delete
FROM RowNumCTE
Where row_num > 1


----------------------------------------------------------------------------------------------------------------

--Delete Unused Columns

Select *
From PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate

