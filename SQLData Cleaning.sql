-- Cleaning Data In Sql Queries--

Select*
From PortfolioProject..NashvilleHousing

--Standrize Date Format

Select SaleDateConverted, Convert(Date,SaleDate) 
From PortfolioProject..NashvilleHousing 

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject..NashvilleHousing
Set SaleDateConverted = Convert(Date,SaleDate) 


--populate Proparty address data--

Select A.[UniqueID ] ,a.parcelID, a.propertyAddress,  b.[UniqueID ]   ,b.ParcelID, b.propertyAddress , IsNull ( a.propertyAddress, b.propertyAddress) 
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	On a.parcelID = b.ParcelID
	And A.[UniqueID ] <> b.[UniqueID ]

Where a.propertyAddress is null;

--Update Property address column--

Update a
Set PropertyAddress = IsNull ( a.propertyAddress, b.propertyAddress) 
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	On a.parcelID = b.ParcelID
	And A.[UniqueID ] <> b.[UniqueID ]

Where a.propertyAddress is null

--Breaking Out Address Into Individual Column (Address, City, State)
Select SUBSTRING(PropertyAddress , 1 ,CHARINDEX(',' , PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',' , PropertyAddress) +1 , LEN(PropertyAddress)) As Street
From PortfolioProject..NashvilleHousing

--Add it to Columns --
Alter Table NashvilleHousing
Add PropertySpliteAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set PropertySpliteAddress = SUBSTRING(PropertyAddress , 1 ,CHARINDEX(',' , PropertyAddress)-1) 

Alter Table NashvilleHousing
Add PropertySpliteStreet Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set PropertySpliteStreet = SUBSTRING(PropertyAddress,CHARINDEX(',' , PropertyAddress) +1 , LEN(PropertyAddress)) 

--Test--
Select PropertySpliteAddress , PropertySpliteStreet
From PortfolioProject..NashvilleHousing

-- Spliting Using ParseName--

Select PARSENAME(Replace(OwnerAddress, ',', '.' ),3)
, PARSENAME(Replace(OwnerAddress, ',', '.' ),2)
,PARSENAME(Replace(OwnerAddress, ',', '.' ),1)
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSpliteAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set OwnerSpliteAddress = PARSENAME(Replace(OwnerAddress, ',', '.' ),3)

Alter Table NashvilleHousing
Add OwnerSpliteStreet Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set OwnerSpliteStreet = PARSENAME(Replace(OwnerAddress, ',', '.' ),2)

Alter Table NashvilleHousing
Add OwnerSpliteState Nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set OwnerSpliteState = PARSENAME(Replace(OwnerAddress, ',', '.' ),1)


Select OwnerSpliteAddress , OwnerSpliteStreet , OwnerSpliteState
From PortfolioProject..NashvilleHousing

                ----------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, Case When SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant ='N' then 'No'
	Else SoldAsVacant
	End
From PortfolioProject..NashvilleHousing


update PortfolioProject..NashvilleHousing 
Set SoldAsVacant = case When SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant ='N' then 'No'
	Else SoldAsVacant
	End

----------------------------------------------------
--Remove Dublicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PortfolioProject.dbo.NashvilleHousing


---------------
-- Delete Unused Columns



Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

