require 'sinatra/activerecord'
require 'elasticsearch/model'

class Tweet < ActiveRecord::Base

	include Elasticsearch::Model
	include Elasticsearch::Model::Callbacks

	has_many :comments
	has_many :commenters, 
	:through => :comments, 
	:source => :user

	has_many :mentions
	has_many :mentioned_users,
	:through => :mentions, 
	:source => :user

	belongs_to :user, class_name: "User"

	has_many :has_tags
	has_many :tags, through: :has_tags

	settings do
		mappings dynamic: false do
			indexes :tweet, type: :text, analyzer: :english
			indexes :mention_str, type: :text
			indexes :tag_str, type: :text
		end
	end

	def as_indexed_json(options = {})
		self.as_json(
		only: [:tweet, :mention_str, :tag_str],
		include: {
			user: {
			only: [:username]
			}
		}
		)
	end

end

# create elasticsearch index
unless Tweet.__elasticsearch__.index_exists?
	Tweet.__elasticsearch__.create_index!
end
# Tweet.__elasticsearch__.import
Tweet.__elasticsearch__.refresh_index!
# Tweet.__elasticsearch__.delete_index!