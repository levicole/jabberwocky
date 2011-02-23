class Subscriber
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :email, String
  property :jid, String
end
