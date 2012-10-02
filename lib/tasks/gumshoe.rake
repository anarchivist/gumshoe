require 'rubygems'
require 'find'
require 'rsolr'
require 'rsolr-ext'
require 'nokogiri'
require 'dfxml_solrizer'

def require_env_file
  raise("The FILE environment variable is required!") if ENV['FILE'].to_s.empty?
  ENV['FILE']
end

namespace :solr do

  desc "Optimize Solr index"
  task :optimize => :environment do
    solr = Blacklight.solr
    solr.optimize
  end

  desc "Commit Solr index"
  task :commit => :environment do
    solr = Blacklight.solr
    solr.commit
  end

  desc "Clear all records from Solr index"
  task :clear => :environment do
    solr = Blacklight.solr
    puts 'Clearing and optimizing Solr index'
    solr.delete_by_query '*:*'
    solr.commit
    solr.optimize
  end

end

namespace :gumshoe do
  
  namespace :image do
    
    desc "Index output from fiwalk"
    task :index => :environment do
      solr = Blacklight.solr
      input_file = require_env_file
      if input_file =~ /\*/
        files = Dir[input_file].collect
      else
        files = [input_file]
      end

      files.each_with_index do |f,index|
        puts "-- start", f
        begin
          mapper = Dfxml::Solrizer.new f
          mapper.get_solr_docs do |d|
            solr.add d
          end
        rescue
          puts "-- uh oh", f
        end
        puts "-- finish", f
      end
      solr.commit
    end
    
    desc "Download sample disk image from digitalcorpora.org"
    task :download do
      FileUtils.mkdir "images" rescue nil
      curl = Curl::Easy.new
      curl.url = "http://digitalcorpora.org/corp/nps/drives/nps-2009-casper-rw/ubnist1.casper-rw.gen2.aff"
      curl.perform
      file = File.new('images/ubnist1.casper-rw.gen2.aff', 'wb')
      file << curl.body_str
      file.close
      puts 'downloaded ubnist1.casper-rw.gen2.aff to images'
    end
  end
end
