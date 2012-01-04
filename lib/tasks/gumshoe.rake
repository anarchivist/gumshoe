require 'rubygems'
require 'find'
require 'rsolr'
require 'rsolr-ext'
require 'nokogiri'
require 'dfxml_mapper'
require 'curl'

def require_env_file
  raise("The FILE environment variable is required!") if ENV['FILE'].to_s.empty?
  ENV['FILE']
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
        mapper = DFXMLMapper.new f
        solr.add mapper.get_solr_docs
      end
      solr.commit
      
    end
    
    desc "Download sample disk image from digitalcorpora.org"
    task :download do
      FileUtils.mkdir "images" rescue nil
      curl = Curl::Easy.new
      curl.url = "http://digitalcorpora.org/corp/images/nps/nps-2009-casper-rw/ubnist1.casper-rw.gen2.aff"
      curl.perform
      file = File.new('images/ubnist1.casper-rw.gen2.aff', 'wb')
      file << curl.body_str
      file.close
      puts 'downloaded ubnist1.casper-rw.gen2.aff to images'
    end
  end
    
end