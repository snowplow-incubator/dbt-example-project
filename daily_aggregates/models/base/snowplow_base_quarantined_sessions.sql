{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}


{{
  config(
    materialized='incremental',
  )
}}

{% set quarantined_query = snowplow_utils.base_create_snowplow_quarantined_sessions() %}

{{ quarantined_query }}
