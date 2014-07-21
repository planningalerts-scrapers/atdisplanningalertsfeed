# ATDISPlanningAlertsFeed

This gem makes it simple to add an [ATDIS feed](http://www.planningalerts.org.au/atdis/specification)
to [https://morph.io/](morph.io) for [PlanningAlerts](http://www.planningalerts.org.au/).

## Usage

* Create a [new scraper](https://morph.io/scrapers/new) on morph.io
* Add this Gem to your `Gemfile`:

```ruby
source 'https://rubygems.org'

gem 'atdisplanningalertsfeed', github: 'planningalerts-scrapers/atdisplanningalertsfeed'
```

* Add this to your `scraper.rb`, replacing the URL:

```ruby
#!/usr/bin/env ruby
Bundler.require

url = 'http://myhorizon.solorient.com.au/Horizon/@@horizondap_uralla@@/atdis/1.0/applications.json'

ATDISPlanningAlertsFeed.save(url)
```

* Run your scraper on morph.io
* :metal:

## Examples

* https://morph.io/planningalerts-scrapers/uralla
* https://morph.io/planningalerts-scrapers/liverpool_plains

## Contributing

1. Fork it ( http://github.com/planningalerts-scrapers/atdisplanningalertsfeed/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
