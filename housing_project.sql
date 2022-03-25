--Cleaning data in sql queries

select * from Housing_data_cleaning_project..housing_data

--Se Date Format standardize

select Data_Converted, CONVERT(Date, saledate)

from Housing_data_cleaning_project..housing_data



alter table housing_data
add housingDataConverted Date;

update housing_data
set Data_Converted = CONVERT(Date, saledate)


--Populate Property Address data

select * from Housing_data_cleaning_project..housing_data
--where PropertyAddress is null
order by ParcelID


select a.ParcelID,  a.PropertyAddress, b.ParcelID, b.PropertyAddress , ISNULL(a.PropertyAddress, b.PropertyAddress)
from Housing_data_cleaning_project..housing_data a
join Housing_data_cleaning_project..housing_data b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)

from Housing_data_cleaning_project..housing_data a
join Housing_data_cleaning_project..housing_data b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]

where a.PropertyAddress is null



--Breaking out address into individual columns (Address, City,State)

select propertyaddress from Housing_data_cleaning_project..housing_data


select 
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) as Address,

SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) + 1 , len(propertyaddress)) as Address

from Housing_data_cleaning_project..housing_data




-------------------------------------------------------------------------------------------------------------------------------------------------

alter table housing_data
add PropertySplitAddrress nvarchar(255);

update housing_data
set PropertySplitAddrress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1)


alter table housing_data
add PropertySplitCity nvarchar(255);

update housing_data
set PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) + 1 , len(propertyaddress))


select * from Housing_data_cleaning_project..housing_data




select owneraddress from Housing_data_cleaning_project..housing_data

--Customize Owner Address

select 

PARSENAME(replace(owneraddress, ',', '.'),3),
PARSENAME(replace(owneraddress, ',', '.'),2),
PARSENAME(replace(owneraddress, ',', '.'),1)

from  Housing_data_cleaning_project..housing_data


----------------------------------------------------------------------------------------------------------------------------------------------------


alter table housing_data
add OwnerSplitAddrress nvarchar(255);

update housing_data
set OwnerSplitAddrress = PARSENAME(replace(owneraddress, ',', '.'),3)


alter table housing_data
add OwnerSplitCity nvarchar(255);

update housing_data
set OwnerSplitCity = PARSENAME(replace(owneraddress, ',', '.'),2)


alter table housing_data
add OwnerSplitState nvarchar(255);

update housing_data
set OwnerSplitState = PARSENAME(replace(owneraddress, ',', '.'),1)


select * from Housing_data_cleaning_project..housing_data




---Change Y and N to Yes, NO in 'SoldAsVacant' field

select distinct(soldasvacant), count(soldasvacant)
from Housing_data_cleaning_project..housing_data

group by SoldAsVacant

order by 2


select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		 end
from Housing_data_cleaning_project..housing_data


update housing_data

set soldasvacant = case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		 end





---------------------------------------------------------------------------------------------------------------------------------------------------

--Removing Duplicates
with rownumcte as(
select *,
	ROW_NUMBER() Over(
	Partition by	ParcelID,
					PropertyAddress,
					SalePrice, SaleDate,
					LegalReference
					order by
						uniqueid)row_num

from Housing_data_cleaning_project..housing_data
)
--order by ParcelID

select * from rownumcte where row_num > 1 order by PropertyAddress





----------------------------------------------------------------------------------------------------------------------------------------------------
--Delete unused columns

select * from Housing_data_cleaning_project..housing_data

alter table Housing_data_cleaning_project..housing_data
drop column propertyaddress, taxdistrict, owneraddress

alter table Housing_data_cleaning_project..housing_data
drop column saledate

----------------------------------------------------------------------------------------------------------------------------------------------------------


