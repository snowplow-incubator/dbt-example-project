{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}


{{
  config(
    materialized = 'incremental',
    unique_key = 'u_key',
    tags= ['daily_aggregates_project_incremental']
    )
}}

select 
session_identifier || event_name as u_key,
    session_identifier,
    event_name,
    count(*) as volume
from 
    {{ ref('snowplow_base_events_this_run') }}
group by 1, 2, 3
