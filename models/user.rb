require 'sinatra/activerecord'
require 'bcrypt'

class User < ActiveRecord::Base
  include BCrypt

  def as_json(options = {})
    super(options.merge({ except: [:password_digest] }))
  end
  
  has_secure_password
  has_many :user_as_idols, 
  :foreign_key => :idol_id,
  :class_name => 'Follow'
  has_many :fans,
  :through => :user_as_idols,
        :foreign_key => :fan_id,
        :class_name => 'User'

  has_many :user_as_fans,
  :foreign_key => :fan_id,
  :class_name => 'Follow'
  has_many :idols,
  :through => :user_as_fans,
        :foreign_key => :idol_id,
        :class_name => 'User'

  has_many :comments
  has_many :comments_in, 
  :through => :comments, 
  :source => :tweet

  has_many :mentions
  has_many :mentioned_in,
  :through => :mentions, 
  :source => :tweet

  has_many :tweets

  
end