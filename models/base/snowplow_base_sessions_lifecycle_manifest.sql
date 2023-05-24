
{% set sessions_lifecycle_manifest_query = snowplow_utils.base_create_snowplow_sessions_lifecycle_manifest(
    var('snowplow__session_identifiers', '{"atomic": "domain_sessionid"}'),
    var('snowplow__session_timestamp', 'collector_tstamp'),
    var('snowplow__user_identifiers', '{"atomic" : "domain_userid"}'),
    var('snowplow__quarantined_sessions', 'snowplow_base_quarantined_sessions'),
    var('snowplow__derived_tstamp_partitioned', true),
    var('snowplow__days_late_allowed', 3),
    var('snowplow__max_session_days', 3),
    var('snowplow__app_ids', []),
    var('snowplow__events_schema', 'atomic'),
    var('snowplow__events_table', 'snowplow_events'),
    var('snowplow__event_limits', 'snowplow_base_new_event_limits'),
    var('snowplow__incremental_manifest', 'snowplow_incremental_manifest')
 ) %}

{{ sessions_lifecycle_manifest_query }}
