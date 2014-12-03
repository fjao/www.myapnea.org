unless Rails.env.test?
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    enable_starttls_auto: true,
    address: ENV['smtp_address'],
    port: ENV['smtp_port'],
    domain: ENV['smtp_domain'],
    authentication: ENV['smtp_authentication'].to_sym, # :plain, :login, or, :cram_md5
    email: ENV['smtp_email'],
    user_name: ENV['smtp_user_name'],
    password: ENV['smtp_password']
  }
else
  ActionMailer::Base.smtp_settings[:email] = "travis-ci@example.com"
end
