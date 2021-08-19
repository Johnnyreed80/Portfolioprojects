select * from portfolioproject.dbo.nashvillehousing

-----------------------------------------------------------------

--Standardize Date Format

Select Saledate, CONVERT(Date,SaleDate)
From portfolioproject.dbo.nashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-----------------------------------------------------------------

--Populate Property Address data

Select PropertyAddress
From portfolioproject.dbo.nashvilleHousing
--where PropertyAddress is Null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.Propertyaddress,b.propertyaddress)
from portfolioproject.dbo.nashvillehousing a
JOIN portfolioproject.dbo.nashvillehousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET propertyaddress = ISNULL(a.Propertyaddress,b.propertyaddress)
from portfolioproject.dbo.nashvillehousing a
JOIN portfolioproject.dbo.nashvillehousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-----------------------------------------------------------------

--Breaking Out Address Into Individual Columns (Address, City, State)

Select PropertyAddress
From portfolioproject.dbo.nashvilleHousing
--where PropertyAddress is Null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From portfolioproject.dbo.nashvilleHousing

ALTER TABLE portfolioproject.dbo.nashvillehousing
Add PropertySplitAddress NVARCHAR(255)

Update portfolioproject.dbo.nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE portfolioproject.dbo.nashvillehousing
Add PropertySplitCity Nvarchar(255);

Update portfolioproject.dbo.nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select * from portfolioproject.dbo.nashvillehousing
where OwnerAddress IS NOT NULL


Select owneraddress from portfolioproject.dbo.nashvillehousing

Select	
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
from portfolioproject.dbo.nashvillehousing

ALTER TABLE portfolioproject.dbo.nashvillehousing
Add OwnerSplitAddress Nvarchar(255);

Update portfolioproject.dbo.nashvillehousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

ALTER TABLE portfolioproject.dbo.nashvillehousing
Add OwnerSplitCity Nvarchar(255);

Update portfolioproject.dbo.nashvillehousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)


ALTER TABLE portfolioproject.dbo.nashvillehousing
Add OwnerSplitState Nvarchar(255);

Update portfolioproject.dbo.nashvillehousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)



-----------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field
https://youtu.be/8rO7ztF4NtU?t=2018

select Distinct(SoldAsVacant), Count(SoldAsVacant)
from portfolioproject.dbo.nashvillehousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant, 
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
from portfolioproject.dbo.nashvillehousing

-----------------------------------------------------------------

--Delete Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY 
		UniqueID
		) row_num

from portfolioproject.dbo.nashvillehousing
--order by ParcelID
)

Select * from RowNumCTE
where row_num > 1
Order by Propertyaddress

Select *
from portfolioproject.dbo.nashvillehousing

-----------------------------------------------------------------

--Delete Unused Columns

Select *
from portfolioproject.dbo.nashvillehousing

ALTER TABLE portfolioproject.dbo.nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE portfolioproject.dbo.nashvillehousing
DROP COLUMN SaleDate