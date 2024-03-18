select *
from Nationalhousing


select saledateconverted, cast(SaleDate as date) as saledatee
from Nationalhousing

update Nationalhousing
set SaleDate = cast(SaleDate as date)

alter table Nationalhousing
add saledateconverted as date

update Nationalhousing
set saledateconverted = cast(SaleDate as date)


-- populate property adderss


select *
from Nationalhousing
--where PropertyAddress is null
order by ParcelID



select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from Nationalhousing a
join Nationalhousing b
   on a.ParcelID = b.ParcelID
   and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from Nationalhousing a
join Nationalhousing b
   on a.ParcelID = b.ParcelID
   and a.[UniqueID ] <> b.[UniqueID ]
   where a.PropertyAddress is null

select *
from Nationalhousing
where PropertyAddress is null


-- breaking out address into individual columns

select PropertyAddress
from Nationalhousing
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) as address,
SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+1, len(propertyaddress)) as address

from Nationalhousing


alter table Nationalhousing
add propertysplitaddress nvarchar(255);

update Nationalhousing
set propertysplitaddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1)


alter table Nationalhousing
add propertysplitcity nvarchar(255);

update Nationalhousing
set propertysplitcity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+1, len(propertyaddress))

select *
from Nationalhousing


select OwnerAddress
from Nationalhousing

select
PARSENAME(replace(OwnerAddress, ',', '.'), 3)
,PARSENAME(replace(OwnerAddress, ',', '.'), 2)
,PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from Nationalhousing


alter table Nationalhousing
add ownersplitaddress nvarchar(255);

update Nationalhousing
set ownersplitaddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)


alter table Nationalhousing
add ownersplitcity nvarchar(255);

update Nationalhousing
set ownersplitcity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

alter table Nationalhousing
add ownersplitstate nvarchar(255);

update Nationalhousing
set ownersplitstate = PARSENAME(replace(OwnerAddress, ',', '.'), 1)



-- changing y and n to yes and no in 'sold as vacant field'


select distinct(SoldAsVacant), count(SoldAsVacant)
from Nationalhousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case 
   when SoldAsVacant = 'y' then 'yes'
   when SoldAsVacant = 'n' then 'no'
   else SoldAsVacant
end
from Nationalhousing


update Nationalhousing
set SoldAsVacant = case 
   when SoldAsVacant = 'y' then 'yes'
   when SoldAsVacant = 'n' then 'no'
   else SoldAsVacant
end
from Nationalhousing


-- removing duplicates

with rownumCTE as (
select *,
     row_number() over (
	 partition by parcelid,
	 propertyaddress,
	 saleprice,
	 saledate,
	 legalreference
	 order by
	  uniqueid
	 ) as rownum

from Nationalhousing
--order by ParcelID
)
delete 
from rownumCTE
WHERE rownum > 1



-- deleting unused column


select*
from Nationalhousing

alter table Nationalhousing
drop column owneraddress, taxdistrict, propertyaddress

alter table Nationalhousing
drop column saledate














