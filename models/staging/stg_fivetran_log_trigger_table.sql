with trigger_table as (

    {{ union_source_tables('trigger_table') }}

),

fields as (

    select 

        table,
        transformation_id,
        destination_database
    
    from trigger_table

    where destination_database is not null
)


select * from fields