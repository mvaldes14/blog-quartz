---
title: Ruby Server Scraper
date: 2022-04-17
description: Automating site scraping because engineers are lazy right?!.
status: Complete
tags: 
- automation
---

As shared in a previous [post](https://blog.mvaldes.dev/selfhosted-2022.html), been looking into expanding my existing homelab and the number of sites that sell used hardware is very limited and having to depend on sites like craiglist, Facebook marketplace was simply not going to cut it, cause first of all I no longer use my Facebook account and craiglist has always been fishy in my opinion...also have had some crappy experiences in there so no thank you. I had 2 options, either find something in reddit's communities or keep an eye on a local store here in Minnesota that basically sells used hardware at very decent prices, shout-out to FGTW for having such sweet components and close to home - https://www.freegeektwincities.org/

So instead of me visiting the site every day, figured I could automate the entire process, cause that's what software engineering is all about!.

Now I've done web scrapers before in python using `beautifulsoup` and `requests`, I wanted to try to do it in another language so Ruby was chosen given on how much I have to use it at work figured it would be a good problem to solve, **because that's how you really learn a new language, by solving a problem you currently have.**

## Enter Ruby

Ruby feels familiar to me in a sense that I can almost read it as as if it were a book, similar experience with Python, with some minor syntax changes which I won't explain here but a quick search will you tell you the main things that sets them apart.

I would argue it's a good first language for anyone to learn. Its OOP based and has a very active community with tons of packages that do all sorts of magical things. Has some good and cherished frameworks so give it a try.

So that being said, here's the logic for the scraper.

1. Start a web process/make a request to the site with HTTParty - equivalent to requests.
2. Parse the contents of the site using nokogiri - equivalent to beautifulsoup.
3. Store the results in a sqlite database on the first run.
4. Evaluate the results on each execution.
5. Schedule it on a server to run every X hours.
6. If a new server is found, notify me via telegram.

**NOTE**: When Scraping sites make sure you don't spam them with requests every X seconds, some sites have policies against this so do it with caution and some common sense people.

Will not go through every single line of code so here's the gist of it!.

We first got to init a DB and create some tables, this is one of the very few scripts I have developed that actually keeps some sort of state, most of the other quick ones just dump stuff either on console or a txt file somewhere, but given that I do not want to see the same results over and over, some sort of state was needed.

```ruby
# Create a DB in the user directory and start the table
def init_db
  db = SQLite3::Database.open "/home/#{ENV['USER']}/git/server_scraper/tracker.db"
  db.execute 'CREATE TABLE IF NOT EXISTS products(product TEXT, added TEXT)'
  db.results_as_hash = true
  db
end
```

With the records in the database now we needed to know when a new server was posted and since I already use telegram to get notified for other situations like my server up-time or when new media is available and when other scripts that automate tasks complete (backups, cleanup, updates, etc.), we could basically use the same logic to get notified when new stuff drops.

```ruby
# Start a telegram client
def init_telegram(token, log)
  if token.nil?
    log.fatal 'Token not loaded, aborting'
    abort
  end
  client = Telebot::Client.new(token)
  # Check if client started correctly
  log.error 'Bot not initialized' if client.get_me.nil?
  client
end
```

The meat and potatoes of the script that ties it all together. In this case no classes were needed cause this is supposed to be simple yet effective.

```ruby
# Launch a request, store the time and parse the results

def main(db, client, chat_id, log)
  # Scrape results from site
  log.info "Starting script at: #{Time.now}"
  url = 'https://www.freegeektwincities.org/computers'
  request = HTTParty.get(url)
  html = Nokogiri::HTML(request)
  products = html.css('.ProductList-title')
  log.info "Found #{products.length} products in site"

  # Validate and Save
  products.children.each do |p|
    check_if_db = db.query 'SELECT * FROM products WHERE product = ?', p.inner_text
    log.info "Checking if #{p.inner_text} exists in the database"
    if check_if_db.count.zero?
      # Save to DB, notify and log
      log.info "Server added to DB: #{p.inner_text}"
      client.send_message(chat_id: chat_id, text: "NEW SERVER POSTED:#{p.inner_text}")
      db.execute 'INSERT INTO products(product, added) VALUES (?,?)', p.inner_text, Time.now.to_s
    else
      log.info 'Server already in the db, skipping'
    end
  end
  client.send_message(chat_id: chat_id, text: "NO NEW SERVER FOUND at #{Time.now}")
end
```

The secrets and tokens are kept as environment variables and loaded when the script is executed. The rest of the code can be found in the repo [here](https://github.com/mvaldes14/server_scraper).

## Final Thoughts

The script is configured via systemd-timers to run every 4 hours which I believe is pretty fair to the site and to my use case. Did struggle a little bit with what CSS selectors to use to actually grab the data from so that it could be stored in the DB, but that's the joy of scraping honestly.

Would say that this script took me maybe like 2 hours from creation until deployment and overall taught me a lot about the language, like how importing works and how to best use the famous `ruby blocks`. Also how the entire `bundler` ecosystem works, what it means to me as a user and how to use it.

Now thanks to this little script I ended up finding a new Dell 7020 computer with a beefy CPU and 32GB of RAM, so now I can use hardware transcoding on my media, spread some of the heavy services that the Dell SFF and Raspberry PI couldn't just keep up with (Prometheus kept restarting once a day, annoying....).

So hopefully you found this somewhat interesting. Remember that the best way to really learn a new technology or language is to actively use it to solve a problem you have!.

Adios 👋
