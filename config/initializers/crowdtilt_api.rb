#When ready, we should change the env parameter to Rails.env

Crowdtilt.configure {key Rails.configuration.crowdtilt_key; secret Rails.configuration.crowdtilt_secret; env 'development'}