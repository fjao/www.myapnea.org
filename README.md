# OpenPPRN

[![Build Status](https://travis-ci.org/openpprn/opn.svg?branch=master)](https://travis-ci.org/openpprn/opn)
[![Dependency Status](https://gemnasium.com/openpprn/opn.svg)](https://gemnasium.com/openpprn/opn)
[![Code Climate](https://codeclimate.com/github/openpprn/opn/badges/gpa.svg)](https://codeclimate.com/github/openpprn/opn)

A collaboration to build an open-source solution for creating patient-powered research networks.

## Installation

```
gem install bundler
```

This README assumes the following installation directory: /var/www/opn

```
cd /var/www

git clone https://github.com/openpprn/opn.git

cd opn

bundle install
```

Install default configuration files for database connection, email server connection, server url, and application name.

```
ruby lib/initial_setup.rb

bundle exec rake db:migrate RAILS_ENV=production

bundle exec rake assets:precompile RAILS_ENV=production
```

Run Rails Server (or use Apache or nginx)

```
rails s
```

Open a browser and go to: [http://localhost:3000](http://localhost:3000)

All done!
