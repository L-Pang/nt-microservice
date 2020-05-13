# entry point
require 'sinatra'
require_relative './models/tweet'
require_relative './models/user'

ENV["RACK_ENV"] ||= "development"
ENV['DB_HOST'] = "gigatwitter-db-postgresql-do-user-7074878-0.db.ondigitalocean.com"
ENV['DB_PASSWORD'] = "iyajy1kgp2nczrpi"

ActiveRecord::Base.establish_connection(ENV['RACK_ENV'].to_sym)

Elasticsearch::Model.client = Elasticsearch::Client.new(
	url: 'http://161.35.6.102:9200/',
	log: true
)
set :database_file, 'config/database.yml'

get '/' do
	"Nano Twitter Microservice".to_json
end

get '/user/:id' do
	id = params[:id].to_i
	Tweet.where(user_id: id).to_json
end

get '/search' do
	# @tweet = Tweet.search(params[:search_term])
	query = params[:query]
	if !query.nil?
		if query.include?('#')
			query = query.scan(/#\w+/).map{|str| str[1..-1]}.join(" ")
			response = Tweet.__elasticsearch__.search(
				query: {
					match: {
					tag_str: query
					}
				}
			).results
		elsif query.include?('@')
			query = query.scan(/@\w+/).map{|str| str[1..-1]}.join(" ")
			response = Tweet.__elasticsearch__.search(
				query: {
					match: {
					mention_str: query,
					}
				}
			).results
		else
			response = Tweet.__elasticsearch__.search(
				query: {
					multi_match: {
					query: query,
					fields: ['tweet^5', 'tag_str', 'mention_str'],
					fuzziness: "AUTO"
				}
			}
			).results
		end
		if !response.nil?
			{
        :res => response,
        :status => "success"
			}.to_json
		else
			{
        :res => nil,
        :status => "failed"
			}.to_json
		end
	end
end
