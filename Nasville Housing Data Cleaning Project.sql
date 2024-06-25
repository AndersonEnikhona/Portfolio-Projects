select *
from NashvilleHousing

--Standardize Date Format

select SaleDateConverted, CONVERT(Date, SaleDate)
from NashvilleHousing



UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

--Standardize Time Format

select SaletimeConverted, CONVERT(time, SaleDate)
from NashvilleHousing



UPDATE NashvilleHousing
SET SaletimeConverted = CONVERT(time, SaleDate)


ALTER TABLE NashvilleHousing
ADD SaletimeConverted time



-- Populate Property Address Date

select *
from NashvilleHousing
where PropertyAddress is null
order by ParcelID



select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is not null


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
--where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out Address into individual columns (Adrress, Cty, State)

select PropertyAddress
from NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

--For Address
select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', propertyaddress)-1) as address

from NashvilleHousing

--For City

select
--SUBSTRING(PropertyAddress, 1, CHARINDEX(',', propertyaddress)-1) as address,
SUBSTRING(PropertyAddress, CHARINDEX(',', propertyaddress)+1, LEN(PropertyAddress)) as address


from NashvilleHousing



UPDATE NashvilleHousing
SET PropertySlitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', propertyaddress)+1, LEN(PropertyAddress))


ALTER TABLE NashvilleHousing
ADD PropertySlitCity nvarchar(255)

ALTER TABLE NashvilleHousing
ADD PropertySlitAddress nvarchar(255)


UPDATE NashvilleHousing
SET PropertySlitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', propertyaddress)-1)


select *
from NashvilleHousing


-- Breaking Things Down By Owner Address Using parsename
select OwnerAddress
from NashvilleHousing
where OwnerAddress is not null


select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from NashvilleHousing
where OwnerAddress is not null



--Then Update



ALTER TABLE NashvilleHousing
ADD OwnerSlitAddress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSlitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)



ALTER TABLE NashvilleHousing
ADD OwnerSlitCity nvarchar(255)


UPDATE NashvilleHousing
SET OwnerSlitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
ADD OwnerSlitState nvarchar(255)


UPDATE NashvilleHousing
SET OwnerSlitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



--Change Y and N to Yes and No in 'sold as vacant' column

select distinct(soldAsVacant), count(soldAsVacant)
from NashvilleHousing
group by soldAsVacant
order by 2


--then we use case statement

select soldAsVacant,
CASE when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 ELSE SoldAsVacant END
from NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 ELSE SoldAsVacant END
from NashvilleHousing



--Remove Duplicate
WITH RowNumCTE AS (
select *,
		ROW_NUMBER () OVER (
		PARTITION BY ParcelID,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY
					 uniqueID) row_num


from NashvilleHousing
--order by parcelID
)
 select*
 from RowNumCTE
 where row_num >1
 order by saledate









--Delete unused columns

select *
from NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN owneraddress, propertyaddress

