require 'cinch'
require 'sequel'

PREFIX = "`"
DB_URL = ENV.has_key?("SEB_DB_URL") ? ENV["SEB_DB_URL"] : "sqlite://"

# Database
db = Sequel.connect(DB_URL)

db.create_table :factoids do
  String :name, primary_key: true
  String :content, text: true
end
factoids = db[:factoids]

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "virc.org.uk"
    c.channels = ["#bottesting"]
    c.user = "seb"
    c.nick = "seb"
  end

  on :message, /#{PREFIX}insfact(?:oid)? ([\w-]+) (.+)/ do |m, name, content|
    factoids.insert(name: name, content: content)
    m.reply "Added #{name} to database."
  end

  on :message, /#{PREFIX}listfact(?:oid)?s/ do |m|
    names = factoids.map(:name)
    if names.empty?
      m.reply "No factoids found"
    else
      m.reply names.join(", ")
    end
  end

  on :message, "#{PREFIX}die" do |m|
    if m.user.nick == "vktec" then
      m.bot.quit "Exiting on admin request"
    else
      m.reply "#{m.user.nick}: Right back at ya!"
    end
  end

  on :message, /#{PREFIX}([\w-]+)/ do |m, name|
    case name when "insfact", "listfacts", "die" then else
    # unless ["insfact", "listfacts"].include? name then
      factoid = factoids[name: name]
      if factoid
        m.reply factoid[:content]
      else
        m.reply "No such factoid '#{name}'"
      end
    end
  end
end

bot.start

