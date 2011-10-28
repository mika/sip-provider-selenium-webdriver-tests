require "rubygems"
require "bundler/setup"
require "selenium-webdriver"
require "rspec"
include RSpec::Expectations

# configuration
begin
    require "ngcpconfig/boot"
rescue LoadError
    $: << File.expand_path('../../lib', __FILE__)
      require "ngcpconfig/boot"
end

Ngcpconfig::Main.getconfig

# execution
describe "AdminPanel" do

  before(:each) do
    if $mode == "local"
      @driver = Selenium::WebDriver.for :firefox
    elsif $mode == "remote"
      # selenium-server.jar running
      @driver = Selenium::WebDriver.for :remote, :url => $remote_instance
    end

    # slows us down, use wait_for() instead
    # @driver.manage.timeouts.implicit_wait = 10

    @verification_errors = []
  end

  after(:each) do
    @driver.quit
    @verification_errors.should == []
  end

  # TODO - error out and skip all other tests if login doesn't work
  def admin_login
    @driver.get "#{$admin_host}/logout"
    @driver.find_element(:id, "login_user").clear
    @driver.find_element(:id, "login_user").send_keys "administrator"
    @driver.find_element(:id, "login_pass").clear
    @driver.find_element(:id, "login_pass").send_keys "administrator"
    @driver.find_element(:css, "input.but.ui-corner-all").click
  end

  it "test_admin_panel_login" do
    admin_login
    # make sure we're logged in
    element_present?(:css, "div.error").should be_false
  end

  it "test_admin_add_domain" do
    admin_login

    @driver.get "#{$admin_host}/domain"

    # make sure that we don't add duplicate domains
    existing_domains = @driver.find_element(:xpath, ".//*[@id='contentplace']").text()
    if /#{$domain}/m.match(existing_domains)
      puts "*** Domain '#{$domain}' exists already, ignoring request to add."
    else
      @driver.find_element(:id, "domainaddtxt").clear
      @driver.find_element(:id, "domainaddtxt").send_keys $domain
      @driver.find_element(:id, "domainadd").click
      element_present?(:css, "div.error").should be_false
      element_present?(:link, $domain).should be_true
    end
  end

  it "test_add_user" do
    admin_login

    @driver.get "#{$admin_host}/account"
    @driver.find_element(:name, "external_id").send_keys $user
    @driver.find_element(:xpath, ".//div[@id='contentplace']/form[2]/button").click

    # make sure external ID isn't already in use
    account_number = @driver.find_element(:xpath, ".//*[@id='contentplace']/h3[1]").text()
    if /VoIP Account #\d/.match(account_number)
      puts "*** Account '#{$user}' exists already, ignoring request to add."
    else
      @driver.find_element(:xpath, ".//div[@id='contentplace']/a/span").click
      @driver.find_element(:name, "external_id").clear
      @driver.find_element(:name, "external_id").send_keys $user
      @driver.find_element(:name, "submit").click
      element_present?(:css, "div.error").should be_false
      element_present?(:css, "div.success").should be_true
    end
  end

  it "test_add_subscriber" do
    admin_login

    # TODO - get rid of span magic in button clicks
    @driver.get "#{$admin_host}/account"
    @driver.find_element(:id, "external_id").clear
    @driver.find_element(:id, "external_id").send_keys $user
    @driver.find_element(:xpath, "//div[@id='contentplace']/form[2]/button").click

    subscriber = @driver.find_element(:xpath, ".//*[@id='contentplace']").text()
    if /Subscribers.*#{$user}@#{$domain}/m.match(subscriber)
      puts "*** Subscriber '#{$user}@#{$domain}' exists already, ignoring request to add."
    else
      @driver.find_element(:xpath, "//div[@id='contentplace']/a[6]/span/span").click
      @driver.find_element(:name, "external_id").clear
      @driver.find_element(:name, "external_id").send_keys $user
      @driver.find_element(:name, "webusername").clear
      @driver.find_element(:name, "webusername").send_keys $user
      @driver.find_element(:id, "edit_webpass").clear
      @driver.find_element(:id, "edit_webpass").send_keys $user
      @driver.find_element(:name, "cc").clear
      @driver.find_element(:name, "cc").send_keys $phone_cc
      @driver.find_element(:name, "ac").clear
      @driver.find_element(:name, "ac").send_keys $phone_ac
      @driver.find_element(:name, "sn").clear
      @driver.find_element(:name, "sn").send_keys $phone_sn
      @driver.find_element(:name, "username").clear
      @driver.find_element(:name, "username").send_keys $user
      @driver.find_element(:id, "edit_pass").clear
      @driver.find_element(:id, "edit_pass").send_keys $user
      @driver.find_element(:name, "submit").click
      element_present?(:css, "div.error").should be_false
      element_present?(:css, "div.success").should be_true
    end
  end

  def element_present?(how, what)
    @driver.find_element(how, what)
    true
  rescue Selenium::WebDriver::Error::NoSuchElementError
    false
  end

  def verify(&blk)
    yield
  rescue ExpectationNotMetError => ex
    @verification_errors << ex
  end
end
