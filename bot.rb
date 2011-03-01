require './config/environment'

require 'blather/client'

setup AppConfig["jabber_id"], AppConfig["jabber_password"]

subscription :request? do |s|
  @subscriber = Subscriber.create(:email => s.from.strip!, :name => s.from.strip!)
  write_to_stream s.approve!
end

after(:subscription, :request? => true) do |s|
  say s.from.strip!, "Welcome! Be sure to change your nick by sending me a message like so.\n/nick New Name"
end

before(:message, :chat? => true) do |m|
  @subscriber = Subscriber.first(:email => m.from.strip!)
end

message :chat?, :body => %r{(https?:// | www\. )[^\s<]+}x do |m|
  if @subscriber
    Subscriber.all(:email.not => m.from.strip!).each do |subscriber|
      say subscriber.email, "#{@subscriber.name} sent a link: #{m.body}"
    end
  end
end

message :chat?, :body => "fortune" do |m|
  say m.from.strip!, fortune
end

message :chat?, :body => %r{/nick\s([\w\s]*)} do |m|
  if @subscriber
    m.body.match(%r{/nick\s([\w\s]*)}) do
      @subscriber.update(:name => $1)
    end
    say m.from, "Your name has been updated to #{@subscriber.name}"
  end
end

message :chat?, :body => %r{/all\s([\w\s]*)} do |m|
  if @subscriber
    m.body.match(%r{/all\s([\w\s]*)}) do
      Subscriber.all(:email.not => m.from.strip!).each do |subscriber|
        say subscriber.email, "#{@subscriber.name}: #{$1}"
      end
    end
  end
end

def fortune
  `fortune`
end
