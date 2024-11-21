{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{{
  config(
    materialized="incremental",
    unique_key='event_id',
    upsert_date_key='derived_tstamp',
    sort='derived_tstamp',
    dist='event_id',
    partition_by = snowplow_utils.get_value_by_target_type(bigquery_val={
      "field": "derived_tstamp",
      "data_type": "timestamp"
    }, databricks_val='derived_tstamp_date'),
    cluster_by=snowplow_unified.get_cluster_by_values('app_errors'),
    tags=["derived"],
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt')),
    tblproperties={
      'delta.autoOptimize.optimizeWrite' : 'true',
      'delta.autoOptimize.autoCompact' : 'true'
    },
    snowplow_optimize=true
  )
}}


select *
  {% if target.type in ['databricks', 'spark'] -%}
   , date(derived_tstamp) as derived_tstamp_date
   {%- endif %}
from {{ ref('snowplow_unified_app_errors_this_run') }}
where {{ snowplow_utils.is_run_with_new_events('snowplow_unified') }} --returns false if run doesn't contain new events, incremental type custom models, those that reference a `_this_run` type table  should make use of the `is_run_with_new_events` macro to only process the table when new events are available in the current run.

/* here we did not change anything, just removed the `enabled` config as it was tied to package variable previously. 
The custom logic was already added as part of the this_run_table,
you could completely remove the this run table and just add the sql from there to here instead of the
above select statement, the config block should be left as is, or changed as and when needed */
