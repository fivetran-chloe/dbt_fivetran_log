with log as (

    {{ union_source_tables('log') }}

),

fields as (

    select
        id as log_id, 
        time_stamp as created_at,
        connector_id as connector_name, -- Note: this misnomer will be changed by Fivetran soon.
        case when transformation_id is not null and event is null then 'TRANSFORMATION'
        else event end as event_type, 
        message_data,
        case 
        when transformation_id is not null and message_data like '%has succeeded%' then 'transformation run success'
        when transformation_id is not null and message_data like '%has failed%' then 'transformation run failed'
        else message_event end as event_subtype,
        transformation_id,
        destination_database

    from log
)

select * from fields 