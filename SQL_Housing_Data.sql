select * from portfolioproject..housingdata

--Standardised Date Column-------------

select New_Date,Convert(Date,SaleDate) as New_Date
from portfolioproject..housingdata

Alter table housingdata
add New_Date Date;

update housingdata
set New_Date=Convert(Date,SaleDate) 

--Populate Property Address--------------------


select ParcelID,propertyAddress
from portfolioproject..housingdata 
where propertyAddress is null

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
from portfolioproject..housingdata a
join portfolioproject..housingdata b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from portfolioproject..housingdata a
join portfolioproject..housingdata b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

 -----Breaking out address into Individual Columns (Address,City,State)----------------------

 select PropertyAddress
from portfolioproject..housingdata 
--where propertyAddress is null

Select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,len(PropertyAddress)) as Address
from portfolioproject..housingdata

Alter table portfolioproject..housingdata
add  SpiltAddress nvarchar(255)

update portfolioproject..housingdata
set SpiltAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter table portfolioproject..housingdata
add Spiltcity nvarchar(255)

update portfolioproject..housingdata
set Spiltcity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,len(PropertyAddress))

Select 
parsename(REPLACE(OwnerAddress,',','.'),3),     --Address
parsename(REPLACE(OwnerAddress,',','.'),2),     --City
parsename(REPLACE(OwnerAddress,',','.'),1)      --State 
from portfolioproject..housingdata


Alter table portfolioproject..housingdata    --Adding new column OwnerSpiltAddress
add  OwnerSpiltAddress nvarchar(255)

update portfolioproject..housingdata          --Addding Values in that Column
set OwnerSpiltAddress=parsename(REPLACE(OwnerAddress,',','.'),3)

Alter table portfolioproject..housingdata       --Adding new column OwnerSpiltCity
add  OwnerSpiltCity nvarchar(255)

update portfolioproject..housingdata             --Addding Values in that Column
set OwnerSpiltCity=parsename(REPLACE(OwnerAddress,',','.'),2)

Alter table portfolioproject..housingdata         --Adding new column OwnerSpiltState
add  OwnerSpiltState nvarchar(255)

update portfolioproject..housingdata               --Adding Values in that column
set OwnerSpiltState=parsename(REPLACE(OwnerAddress,',','.'),1)


------------Convert Y and N to Yes and No----------------
select 
case when SoldAsVacant='Y' then 'Yes'
     when SoldAsVacant='N' then 'No'
     Else SoldAsVacant
	 End
from portfolioproject..housingdata

update portfolioproject..housingdata
set SoldAsVacant=case when SoldAsVacant='Y' then 'Yes'
     when SoldAsVacant='N' then 'No'
     Else SoldAsVacant
	 End


---------- Remove Duplicate---------------------

With RowNumCTE as(
Select *,
        Row_Number() Over(
		Partition by  ParcelID,
		         PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
				 UniqueID
				 )row_num
		from portfolioproject..housingdata
		)
Delete  From RowNumCTE
where row_num>1



-------------Delete Unused Columns------------
Select * from portfolioproject..housingdata

Alter table portfolioproject..housingdata
Drop column OwnerAddress,TaxDistrict,PropertyAddress

Alter table portfolioproject..housingdata
Drop column saleDate