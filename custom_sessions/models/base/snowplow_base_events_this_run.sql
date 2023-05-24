{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{%- set lower_limit, upper_limit = snowplow_utils.return_limits_from_model(ref(var('snowplow__base_sessions')),
                                                                            'start_tstamp',
                                                                            'end_tstamp') %}

{% set base_events_query = snowplow_utils.base_create_snowplow_events_this_run(
    sessions_this_run_table=var('snowplow__base_sessions'),
    session_identifiers=var('snowplow__session_identifiers'),
    session_timestamp=var('snowplow__session_timestamp'),
    derived_tstamp_partitioned=var('snowplow__derived_tstamp_partitioned', true),
    days_late_allowed=var('snowplow__days_late_allowed', 3),
    max_session_days=var('snowplow__max_session_days', 3),
    app_ids=var('snowplow__app_ids', []),
    snowplow_events_schema=var('snowplow__events_schema', 'atomic'),
    snowplow_events_table=var('snowplow__events_table', 'events'),
    entities_or_sdes=var('snowplow__entities_or_sdes', ''),
    custom_sql=var('snowplow__custom_sql', '')) %}

{{ base_events_query }}
