require 'atdisplanningalertsfeed/version'
require 'atdis'
require 'scraperwiki-morph'

module ATDISPlanningAlertsFeed
  def self.save(url, options = {})
    feed = ATDIS::Feed.new(url)
    options[:lodgement_date_start] = (options[:lodgement_date_start] || Date.today - 30)
    options[:lodgement_date_end] = (options[:lodgement_date_end] || Date.today)
    page = feed.applications(lodgement_date_start: options[:lodgement_date_start], lodgement_date_end: options[:lodgement_date_end])

    # Save the first page
    save_page(page)

    while page = page.next_page
      save_page(page)
    end
  end

  def self.save_page(page)
    puts "Saving page #{page.pagination.current} of #{page.pagination.pages}"

    page.response.each do |item|
      application = item.application

      # TODO: Only using the first address because PA doesn't support multiple addresses right now
      address = application.locations.first.address.street + ', ' +
                application.locations.first.address.suburb + ', ' +
                application.locations.first.address.state  +
                application.locations.first.address.postcode

      record = {
        council_reference: application.info.dat_id,
        address:           address,
        description:       application.info.description,
        info_url:          application.reference.more_info_url.to_s,
        comment_url:       application.reference.comments_url.to_s,
        date_scraped:      Date.today,
        date_received:     application.info.lodgement_date,
        on_notice_from:    application.info.notification_start_date,
        on_notice_to:      application.info.notification_end_date
      }

      if (ScraperWikiMorph.select("* from data where `council_reference`='#{record[:council_reference]}'").empty? rescue true)
        ScraperWikiMorph.save_sqlite([:council_reference], record)
      else
        puts "Skipping already saved record " + record[:council_reference]
      end
    end
  end
end
