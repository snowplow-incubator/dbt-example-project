{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{{
  config(
       post_hook=["{{snowplow_utils.print_run_limits(this, 'daily_aggregates_project')}}"],
    )
}}


{%- set models_in_run = snowplow_utils.get_enabled_snowplow_models(package_name='daily_aggregates_project') -%}

{% set min_last_success,
        max_last_success,
        models_matched_from_manifest,
        has_matched_all_models = snowplow_utils.get_incremental_manifest_status(ref('snowplow_incremental_manifest'),
                                                                                models_in_run) -%}

{% set run_limits_query = snowplow_utils.get_run_limits(min_last_success,
                                                        max_last_success,
                                                        models_matched_from_manifest,
                                                        has_matched_all_models,
                                                        var("snowplow__start_date")) -%}


{{ run_limits_query }}
