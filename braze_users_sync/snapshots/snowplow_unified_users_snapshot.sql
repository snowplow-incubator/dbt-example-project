{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{% snapshot snowplow_unified_users_snapshot %}

{{
    config(
      target_schema=target.schema~'_scratch',
      unique_key='user_identifier',
      strategy='timestamp',
      updated_at='model_tstamp',
    )
}}

select * from {{ ref('snowplow_unified_users') }} 

{% endsnapshot %}
