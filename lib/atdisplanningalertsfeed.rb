require 'atdisplanningalertsfeed/version'
require 'atdis'
require 'scraperwiki-morph'
require 'cgi'

module ATDISPlanningAlertsFeed
  def self.save(url, options = {})
    feed = ATDIS::Feed.new(url)
    logger = options[:logger]
    logger ||= Logger.new(STDOUT)

    options[:lodgement_date_start] = (options[:lodgement_date_start] || Date.today - 30)
    options[:lodgement_date_end] = (options[:lodgement_date_end] || Date.today)
    start_page = feed.applications(lodgement_date_start: options[:lodgement_date_start], lodgement_date_end: options[:lodgement_date_end])

    # Grab all of the pages
    pages = self.fetch_all_pages(start_page, logger)

    records = []
    pages.each do |page|
      additional_records = collect_records(page, logger)
      # If there are no more records to fetch, halt processing
      # regardless of pagination
      break unless additional_records.any?
      records += additional_records
    end

    self.persist_records(records, logger)
  end

  private

  def self.fetch_all_pages(page, logger)
    pages = [page]
    pages_processed = [page.pagination.current]
    while page = page.next_page
      # Some ATDIS feeds incorrectly provide pagination
      # and permit looping; so halt processing if we've already processed this page
      unless pages_processed.index(page.pagination.current).nil?
        logger.info("Page #{page.pagination.current} already processed; halting")
        break
      end
      pages << page
      pages_processed << page.pagination.current 
      logger.debug("Fetching #{page.next_url}")
    end

    pages
  end

  def self.collect_records(page, logger)
    page.response.collect do |item|
      application = item.application

      # TODO: Only using the first address because PA doesn't support multiple addresses right now
      address = application.locations.first.address.street + ', ' +
                application.locations.first.address.suburb + ', ' +
                application.locations.first.address.state  + ' ' +
                application.locations.first.address.postcode

      record = {
        council_reference: CGI.unescape(application.info.dat_id),
        address:           address,
        description:       application.info.description,
        info_url:          application.reference.more_info_url.to_s,
        comment_url:       application.reference.comments_url.to_s,
        date_scraped:      Date.today,
        date_received:     (application.info.lodgement_date.to_date if application.info.lodgement_date),
        on_notice_from:    (application.info.notification_start_date.to_date if application.info.notification_start_date),
        on_notice_to:      (application.info.notification_end_date.to_date if application.info.notification_end_date)
      }
    end
  end

  def self.persist_records(records, logger)
    records.each do |record|
      if (ScraperWikiMorph.select("* from data where `council_reference`='#{record[:council_reference]}'").empty? rescue true)
        ScraperWikiMorph.save_sqlite([:council_reference], record)
      else
        logger.info "Skipping already saved record " + record[:council_reference]
      end
    end

    records
  end
end
