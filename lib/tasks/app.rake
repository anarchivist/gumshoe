require 'rubygems'
require 'find'
require 'rsolr'
require 'nokogiri'
require 'fiwalk_mapper'

def require_env_file
  raise("The FILE environment variable is required!") if ENV['FILE'].to_s.empty?
  ENV['FILE']
end

namespace :app do
  
  namespace :index do
    
    desc "Index output from fiwalk"
    task :fiwalk => :environment do
      solr = Blacklight.solr
    
      input_file = require_env_file
      if input_file =~ /\*/
        files = Dir[input_file].collect
      else
        files = [input_file]
      end
      
      files.each_with_index do |f,index|
        mapper = FiwalkMapper.new f
        solr.add mapper.get_solr_docs
      end
      solr.commit
      
    end
  end
end