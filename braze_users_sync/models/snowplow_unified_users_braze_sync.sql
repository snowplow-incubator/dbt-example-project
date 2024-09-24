{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}


{{
  config(
      materialized='incremental' if var('snowplow__braze_column_based_sync', false) else 'view'
  )
}}

{# identify the columns to be processed #}

{% if var('snowplow__braze_columns_to_include') | length == 0 %}

  {# all columns except for snowplow__braze_columns_to_exclude will be processed, default but not advised leaving it like this #}
  {% do exceptions.warn("Snowplow Warning: The variable `snowplow__braze_columns_to_include` does not contain any fields, all fields from the users table will be processed for the Braze Sync apart from the ones specified in the snowplow__braze_columns_to_exclude. It is advised to change the configuration to a fixed set of columns to prevent issues when new columns are added.") %}
  {% set cols_to_exclude = ['dbt_scd_id', 'dbt_updated_at', 'dbt_valid_from', 'dbt_valid_to'] %}
  {% set cols_to_exclude = cols_to_exclude + (var('snowplow__braze_columns_to_exclude')) %}
  {% set col_string = dbt_utils.star(ref('snowplow_unified_users_snapshot'), except=cols_to_exclude) | replace('"','') | replace(' ','') | replace('\n','') | lower %}
  
  {% set col_arr = col_string.split(',') %}
   
{% else %}

  {% set col_arr = var('snowplow__braze_columns_to_include') %}

{% endif %}

{# check if it reaches the limit #}
{% if col_arr | length > 250 %}
  {{ exceptions.raise_compiler_error(
      "Snowplow Error: There are more than 250 columns set to be processed for the Braze sync, which is above Braze's limit, please adjust snowplow__braze_columns_to_include / exclude columns and try again."
    ) }}
{% endif %}

{# define the method of comparison #}

{% if var('snowplow__braze_column_based_sync', false) %}

  with user_source_obj as (
    
    select
      dbt_updated_at as updated_at
      , s.user_identifier as external_id
      , object_construct(
            {% for col in col_arr -%}
              '{{ col }}', {{ col }}{% if not loop.last %}, {% endif %}
            {% endfor %}) as payload
        
      from {{ ref('snowplow_unified_users_snapshot') }} s
      
      where dbt_valid_to is null 
      
      {% if is_incremental() %}
        and dbt_updated_at > (select max(updated_at) from {{ this }})
      {% endif %}
  )
  
  {% if is_incremental() %}
  
    , previous_user_data as (
    
      select 
        p.external_id, 
        f.key::varchar as key, 
        f.value::variant as value, 
        p.updated_at
        
      from {{ this }} p,
      table(flatten(input => parse_json(p.payload))) f
      
      qualify row_number() over (partition by p.external_id, f.key order by p.updated_at desc) = 1
    )
  {% endif %}

  , current_values as (
    
    select 
      u.external_id, 
      v.key::varchar as key, 
      v.value::variant as value, 
      u.updated_at
      
    from user_source_obj u,
    table(flatten(input => u.payload)) v
  )

  select
    max(c.updated_at) as updated_at,
    c.external_id,
    to_json(object_agg(c.key, c.value)) as payload
      
  from current_values c
  
  {% if is_incremental() %}
  
      left join previous_user_data p on c.external_id = p.external_id and c.key = p.key
      
      where ifnull(c.value::string, '|') != ifnull(p.value::string, '|') and c.external_id is not null and c.external_id <> ''
  
  {% else %}
  
    where external_id is not null and external_id <> ''
    
  {% endif %}
  
  group by 2

{% else %}

{# update the latest rows as they are captured by dbt snapshot #}

  with convert_to_json as (
    
    select
    
      dbt_updated_at as updated_at
      , user_identifier as external_id
      , to_json(object_construct(
            {% for col in col_arr -%}
              '{{ col }}', {{ col }}{% if not loop.last %}, {% endif %}
            {% endfor %})
          ) as payload
      
    from {{ ref('snowplow_unified_users_snapshot') }}
    where dbt_valid_to is null
    
  )
    select * 

    from convert_to_json

    where external_id is not null and external_id <> ''

{% endif %}

