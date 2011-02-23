require './config/environment'

require 'blather/client'

setup AppConfig["jabber_id"], AppConfig["jabber_password"]

subscription :request? do |s|
  puts "#{s.from} - has requested a subscription"
  if subscriber?(s.from.strip!)
    @subscriber.update(:jid => s.from)
  else
    @subscriber = Subscriber.create(:jid => s.from, :email => s.from.strip!, :name => s.from.strip!)
  end
  write_to_stream s.approve!
end

after(:subscription, :request? => true) do |s|
  sleep 5
  say s.from, "Welcome to the dudes of CH jabber bot. Be sure to change your nick by sending me a message like so.\n/nick New Name"
end

message :chat?, :body => %r{(https?:// | www\. )[^\s<]+}x do |m|
  if subscriber?(m.from.strip!)
    Subscriber.all(:email.not => m.from.strip!).each do |subscriber|
      say subscriber.jid, "#{@subscriber.name} sent a link: #{m.body}"
    end
  end
end

message :chat?, :body => "fortune" do |m|
  say m.from, fortune
end

message :chat?, :body => %r{/nick\s([\w\s]*)} do |m|
  if subscriber?(m.from.strip!)
    m.body.match(%r{/nick\s([\w\s]*)}) do
      @subscriber.update(:name => $1)
    end
    say m.from, "Your name has been updated to #{@subscriber.name}"
  end
end

message :chat?, :body => %r{/all\s([\w\s]*)} do |m|
  if subscriber?(m.from.strip!)
    m.body.match(%r{/all\s([\w\s]*)}) do
      Subscriber.all(:email.not => m.from.strip!).each do |subscriber|
        say subscriber.jid, "#{@subscriber.name} says: #{m.body}"
      end
    end
  end
end

message :chat?, :body => %r{/default\s([\w\s]*)} do |m|
  if subscriber?(m.from.strip!)
    @subscriber.update(:jid => m.from)
  end
end

presence do |p|
  puts p.from
  if subscriber?(p.from.strip!)
    @subscriber.update(:jid => p.from)
  else
    @subscriber = Subscriber.create(:name => p.from.strip!, :email => p.from.strip!, :jid => p.from)
  end
end

def fortune
  `fortune`
end

def subscriber?(email)
  @subscriber = Subscriber.first(:email => email)
end
