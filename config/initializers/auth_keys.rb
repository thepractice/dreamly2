AUTH_CONFIG = YAML.load_file("#{::Rails.root}/config/auth_keys.yml")[::Rails.env]