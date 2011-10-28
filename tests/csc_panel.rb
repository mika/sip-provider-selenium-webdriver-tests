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
describe "CSCPanel" do

  before(:each) do
    if $mode == "local"
      @driver = Selenium::WebDriver.for :firefox
    elsif $mode == "remote"
      # when selenium-server.jar is running
      @driver = Selenium::WebDriver.for :remote, :url => $remote_instance
    end

    @driver.manage.timeouts.implicit_wait = 10
    @verification_errors = []
  end

  after(:each) do
    @driver.quit
    @verification_errors.should == []
  end

  it "test_c_s_c_login" do
    @driver.get "#{$csc_host}/logout"
    element_present?(:class, "language").should be_true
    element_present?(:id , "do_login").should be_true

    ## TODO - improve check, based on real content
    # french
    element_present?(:xpath, "//*[@id='menusmall']/li[3]/a").should be_true
    # spanish
    element_present?(:xpath, "//*[@id='menusmall']/li[2]/a").should be_true
    # english
    element_present?(:xpath, "//*[@id='menusmall']/li[1]/a").should be_true

    @driver.get "#{$csc_host}/login?lang=en"
    @driver.find_element(:id, "benutzer").clear
    @driver.find_element(:id, "benutzer").send_keys "#{$user}@#{$domain}"
    @driver.find_element(:id, "passwort").clear
    @driver.find_element(:id, "passwort").send_keys "#{$user}"
    @driver.find_element(:id, "do_login").click
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

