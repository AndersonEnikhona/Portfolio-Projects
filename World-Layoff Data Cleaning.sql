#Data cleaning

select *
from layoffs;

#Remove Duplicate
#Standardize the Data
#Null values or Blank values
#Remove unuseful columns


#Create a duplicate table

create table layoffs_staging
like layoffs;

select *
from layoffs_staging;

insert layoffs_staging
select *
from layoffs;

#Remove Duplicate
# In situation where we dont have an id number or special number row then we first do a row number and also used to check for duplicates

select *, row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions
) as row_num
from layoffs_staging;

with duplicate_cte as
(select *, row_number() over(partition by company, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select *
from duplicate_cte
where row_num > 1;


select *, row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions
) as row_num
from layoffs_staging;

with duplicate_cte as
(select *, row_number() over(partition by company, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
delete
from duplicate_cte
where row_num > 1;





CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


select *
from layoffs_staging2;

insert into layoffs_staging2
select *, 
row_number() 
over(partition by company, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) as row_num
from layoffs_staging;

select *
from layoffs_staging2
where row_num > 1;

delete
from layoffs_staging2
where row_num > 1;

select *
from layoffs_staging2;


#Standardizing the Data
#finding isssues with your data and fixing it by going through each row 


select company, trim(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

#check for industry that are the same and group them together if any 
select distinct(industry)
from layoffs_staging2
order by 1 ;

select *
from layoffs_staging2
where industry like 'Crypto%';

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';



select distinct (location)
from layoffs_staging2
order by 1 ;

update layoffs_staging2
set location = 'Malma'
where location like 'MalmÃ¶%';


select distinct (country)
from layoffs_staging2
order by 1 ;

select distinct (country), trim(trailing '.' from country)
from layoffs_staging2
order by 1 ;

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';


#make sure your data is well formated if not change them e.g string to date
select `date`,
str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;

Update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

select `date`
from layoffs_staging2;

alter table layoffs_staging2
modify column `date` DATE;



Select *
from layoffs_staging2;



#Null values or Blank values
Select *
from layoffs_staging2
where total_laid_off is null and percentage_laid_off is null;

Select *
from layoffs_staging2
where industry is null or industry = '';

#Populating Null and Blank with values
#for the company with null or blank industry check if it has another one with same company name that is populated

Select *
from layoffs_staging2
where company = 'Juul';

update layoffs_staging2
set industry = 'Consumer'
where company like 'Juul%';


#Remove unuseful columns
Select *
from layoffs_staging2;

#We have to delete those with no total laid off and percentage laid off.
Select *
from layoffs_staging2
where total_laid_off is null and percentage_laid_off is null;


delete
from layoffs_staging2
where total_laid_off is null and percentage_laid_off is null;


#We get rid of the row_num column by dropping the column
select*
from layoffs_staging2;

alter table layoffs_staging2
drop column row_num