# Detect new pages from RSS feeds
require "rss"
require "uri"

base_url = "https://blog.zunda.ninja"
latest_rss = "./_site/feed.xml"
public_rss = base_url + "/feed.xml"

begin
  # Compare paths of posts.
  # ignoring shceme and hostname which maybe different with `jekyll serve`
  new_paths = [
    RSS::Parser.parse(File.read(latest_rss)), # current build
    RSS::Parser.parse(public_rss)             # prebious deploy
  ].map{|feed| feed.items.map{|item| URI.parse(item.link.href).path}}.inject(:-)

  if new_paths.empty?
    puts "No new pages."
  else
    puts "New pages:\n#{new_paths.map{|path| base_url + path}.join("\n")}"
  end
rescue => e
  # Let build continue even we failed finding new pages
  puts "#{e.message}\n\tfrom #{e.backtrace.last}"
end
