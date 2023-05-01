-- Cleaning Data

Select * 
from PortfolioProject..NashvilleHousing


-- Standardize Data Format
Select SaleDateConverted, CONVERT(date, SaleDate)
from PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(date, SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(date, SaleDate)


-- Populate Property Address Data
Select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
from PortfolioProject..NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
from PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select * 
from PortfolioProject..NashvilleHousing


Select OwnerAddress
from PortfolioProject..NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject..NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

Select * 
from PortfolioProject..NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, Case when SoldAsVacant = 'Y' Then 'Yes'
	   When	SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
from PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes'
	   When	SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End


-- Remove Duplicates
With RowNumCTE as(
Select *,
	ROW_NUMBER() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num

from PortfolioProject..NashvilleHousing
--order by ParcelID
)
Select *
from RowNumCTE
where row_num > 1
order by PropertyAddress


-- Delete Unused Columns

Select * 
from PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject..NashvilleHousing
Drop Column SaleDate