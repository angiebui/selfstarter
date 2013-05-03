if Rails.configuration.crowdtilt_mode == 'sandbox'

	Crowdtilt.configure api_key: Rails.configuration.crowdtilt_sandbox_key,
	                    api_secret: Rails.configuration.crowdtilt_sandbox_secret,
	                    mode: Rails.configuration.crowdtilt_mode
else

	Crowdtilt.configure api_key: Rails.configuration.crowdtilt_production_key,
	                    api_secret: Rails.configuration.crowdtilt_production_secret,
	                    mode: Rails.configuration.crowdtilt_mode

end