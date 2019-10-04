require 'open-uri'
require 'uri'
require 'selenium-webdriver'


if ARGV.size < 1
   puts "usage: #{__FILE__} URL"
end

url = ARGV.first

options = Selenium::WebDriver::Chrome::Options.new
options.add_argument('--headless')
driver = Selenium::WebDriver.for(:chrome, options: options)

driver.get(url)

driver.find_elements(:xpath, '//div[@style]/img').each do |elm|
   img_url = elm.attribute('src')
   img = open(img_url).read
   fname = File.basename(URI.parse(img_url).path)
   File.open(fname, 'wb').write(img)
end

