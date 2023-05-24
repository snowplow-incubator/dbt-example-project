{%- set lower_limit, upper_limit = snowplow_utils.return_limits_from_model(ref(var('snowplow__base_sessions', 'snowplow_base_sessions_this_run')),
                                                                          'start_tstamp',
                                                                          'end_tstamp') %}

{% set base_events_query = snowplow_utils.base_create_snowplow_events_this_run(
    var('snowplow__base_sessions', 'snowplow_base_sessions_this_run'),
    var('snowplow__session_identifiers', '{"atomic": "domain_sessionid"}'),
    var('snowplow__session_timestamp', 'collector_tstamp'),
    var('snowplow__derived_tstamp_partitioned', true),
    var('snowplow__days_late_allowed', 3),
    var('snowplow__max_session_days', 3),
    var('snowplow__app_ids', []),
    var('snowplow__events_schema', 'atomic'),
    var('snowplow__events_table', 'events')) %}

{{ base_events_query }}
