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



namespace :gumshoe do

  namespace :index do
    desc "Optimize Solr index"
    task :optimize => :environment do
      solr = Blacklight.solr
      solr.optimize
    end
    
    desc "Remove all records from Solr index"
    task :nuke => :environment do
      puts "deleting all records from index"
      solr = Blacklight.solr
      solr.delete_by_query '*:*'
      solr.commit
    end
  end
  
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
      count = 0
      files.each_with_index do |f,index|
        mapper = Dfxml::Solrizer.new f
          mapper.get_solr_docs do |d|
            solr.add d
            count += 1
          end
      end
      solr.commit
      puts count.to_s << " records added"
    end
    
    namespace :download do
      desc "Download sample aff disk image from digitalcorpora.org"
      task :aff do
        FileUtils.mkdir "images" rescue nil
        curl = Curl::Easy.new
        curl.url = "http://digitalcorpora.org/corp/nps/drives/nps-2009-casper-rw/ubnist1.casper-rw.gen2.aff"
        curl.perform
        file = File.new('images/ubnist1.casper-rw.gen2.aff', 'wb')
        file << curl.body_str
        file.close
        puts 'downloaded ubnist1.casper-rw.gen2.aff to images'
      end

      desc "Download a sample ewf disk image from digitalcorpora.org"
      task :ewf do
        FileUtils.mkdir "images" rescue nil
        curl = Curl::Easy.new
        curl.url = "http://digitalcorpora.org/corp/nps/drives/nps-2009-canon2/nps-2009-canon2-gen6.E01"
        curl.perform
        file = File.new('images/nps-2009-canon2-gen6.E01', 'wb')
        file << curl.body_str
        file.close
        puts 'downloaded nps-2009-canon2-gen6.E01 to images'
      end
    
      desc "Download a sample raw disk image from digitalcorpora.org"
      task :raw do
        FileUtils.mkdir "images" rescue nil
        curl = Curl::Easy.new
        curl.url = "http://digitalcorpora.org/corp/nps/drives/nps-2009-canon2/nps-2009-canon2-gen1.raw"
        curl.perform
        file = File.new('images/nps-2009-canon2-gen1.raw', 'wb')
        file << curl.body_str
        file.close
        puts 'downloaded nps-2009-canon2-gen1.raw to images'
      end
    end
  end
    
end
