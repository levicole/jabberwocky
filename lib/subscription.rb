class Subscription
  include DataMapper::Resource

  property :id, Serial
  property :subscriber_id, Integer
  property :jid, String

end
