with table_mar as (
    
    select *
    from {{ ref('fivetran_log_mar_table_history') }}
),

destination_mar as (

    select 
        measured_month,
        destination_id,
        destination_name,
        destination_database,
        sum(monthly_active_rows) as monthly_active_rows
    
    from table_mar
    group by 1,2,3,4
),

credits_used as (

    select 
        destination_id,
        credits_consumed,
        cast(concat(measured_month, '-01') as date) as measured_month -- match date format to join with MAR table

    from {{ ref('stg_fivetran_log_credits_used') }}
),

join_credits_mar as (

    select 
        destination_mar.measured_month,
        destination_mar.destination_id,
        destination_mar.destination_name,
        destination_mar.destination_database,
        credits_used.credits_consumed,
        destination_mar.monthly_active_rows,
        round( nullif(credits_used.credits_consumed,0) * 1000000.0 / nullif(destination_mar.monthly_active_rows,0), 2) as credits_per_million_mar,
        round( nullif(destination_mar.monthly_active_rows,0) * 1.0 / nullif(credits_used.credits_consumed,0), 0) as mar_per_credit

    from 
    destination_mar left join credits_used 
        on destination_mar.measured_month = credits_used.measured_month
        and destination_mar.destination_id = credits_used.destination_id

)

select * from join_credits_mar
order by measured_month desc