{{
    config(
        post_hook=["{{ snowplow_utils.base_quarantine_sessions(var('snowplow__max_session_days', 3), 'snowplow_base_quarantined_sessions') }}"]
    )
}}


{% set sessions_query = snowplow_utils.base_create_snowplow_sessions_this_run(lifecycle_manifest_table='snowplow_base_sessions_lifecycle_manifest', new_event_limits_table='snowplow_base_new_event_limits') %}

{{ sessions_query }}
