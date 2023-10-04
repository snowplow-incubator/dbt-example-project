{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{{
  config(
    materialized='incremental',
    unique_key='session_identifier',
    upsert_date_key='start_tstamp',
    sort='start_tstamp',
    dist='session_identifier',
    partition_by = snowplow_utils.get_value_by_target_type(bigquery_val={
      "field": "start_tstamp",
      "data_type": "timestamp"
    }, databricks_val='start_tstamp_date'),
    snowplow_optimize = true
  )
}}


{% set sessions_lifecycle_manifest_query = snowplow_utils.base_create_snowplow_sessions_lifecycle_manifest(
    session_identifiers=var('snowplow__session_identifiers'),
    session_timestamp=var('snowplow__session_timestamp', 'collector_tstamp'),
    user_identifiers=var('snowplow__user_identifiers'),
    quarantined_sessions=var('snowplow__quarantined_sessions', 'internal_snowplow_base_quarantined_sessions'),
    derived_tstamp_partitioned=var('snowplow__derived_tstamp_partitioned', true),
    days_late_allowed=var('snowplow__days_late_allowed', 3),
    max_session_days=var('snowplow__max_session_days', 3),
    app_ids=var('snowplow__app_ids', []),
    snowplow_events_schema=var('snowplow__events_schema', 'atomic'),
    snowplow_events_table=var('snowplow__events_table', 'snowplow_events'),
    event_limits_table=var('snowplow__event_limits', 'snowplow_base_new_event_limits'),
    incremental_manifest_table=var('snowplow__incremental_manifest', 'snowplow_incremental_manifest')
) %}

{{ sessions_lifecycle_manifest_query }}
