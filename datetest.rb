require 'rsolr'

solr = RSolr.connect :url => 'http://localhost:8983/solr'

solr.add :id=>1, :text => "This is a test"

solr.commit

response = solr.get 'select', :params => {
  :q=>'*',
  :start=>0,
  :rows=>10
}
response["response"]["docs"].each{|doc| puts doc["id"] }