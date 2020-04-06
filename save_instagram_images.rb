require "open-uri"
require "uri"

require "selenium-webdriver"

def main(args)
  if args.size < 1
    puts "usage: #{__FILE__} URL"
  end
  url = args.first

  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--headless")
  driver = Selenium::WebDriver.for(:chrome, options: options)
  images = fetch_images(driver, url)

  dir = Pathname.new("images")
  save_images(images, dir)

  puts "==> Saved #{images.size} images."
end

def fetch_images(driver, url)
  driver.get(url)

  # Repeatedly click next buttons
  (0..).each do |i|
    but_elms = driver.find_elements(:xpath, "//button[@class and @tabindex]")
    if but_elms.empty? || (but_elms.size == 1 && i > 0)
      break
    else
      next_but = but_elms.last
      next_but.click
    end
  end

  driver.find_elements(:xpath, "//div[@style]/img").map do |elm|
    img_url = elm.attribute("src")
    uri = URI.parse(img_url)
    fname = File.basename(uri.path)
    img = OpenURI.open_uri(img_url).read
    { fname: fname, img: img }
  end
end

def save_images(images, dir)
  dir = Pathname.new(dir)
  dir.mkpath unless dir.directory?
  images.each do |img|
    File.open(dir / img[:fname], "wb").write(img[:img])
  end
end

if $0 == __FILE__
  main(ARGV)
end
