#Exporatory Data Analysis (EDA)

select *
from layoffs_staging2;


select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2;


select *
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc;

select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

select min(`date`), max(`date`)
from layoffs_staging2;

select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;


select year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 2 desc;

select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc;

# A rolling total for percentage layoff by the year and month

select *
from layoffs_staging2;

select substring(`date`,1,7) as `Month`, sum(total_laid_off)
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `Month`
order by `Month`;


# Let's do a rolling total on total laid off based on year/month using CTEs
with rolling_total as
(
select substring(`date`,1,7) as `Month`, sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `Month`
order by 1 asc
)
select `Month`, total_off, sum(total_off) over(order by `Month`) as rolling_total
from rolling_total;



# Company layoff total by year
select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;


select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order by company asc;

with company_year (company, years, total_laid_off) as
(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order by company asc
)
select *
from company_year;

#Highest laid off by each comapany by year
with company_year (company, years, total_laid_off) as
(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order by company asc
)
select *, dense_rank() over (partition by years order by total_laid_off desc) as ranking
from company_year
where years is not null
order by ranking;


with company_year (company, years, total_laid_off) as
(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order by company asc
), company_Year_Rank as
(select *, dense_rank() over (partition by years order by total_laid_off desc) as ranking
from company_year
where years is not null
)
select *
from Company_Year_Rank
where ranking  <= 5;




