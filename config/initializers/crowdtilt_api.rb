if Rails.configuration.crowdtilt_mode == 'production'
  Crowdtilt.configure {key Rails.configuration.crowdtilt_key; secret Rails.configuration.crowdtilt_secret; env 'production'}
else
  Crowdtilt.configure {key Rails.configuration.crowdtilt_sandbox_key; secret Rails.configuration.crowdtilt_sandbox_secret; env 'development'}
end