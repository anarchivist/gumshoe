require_dependency( 'vendor/plugins/blacklight/app/controllers/catalog_controller.rb')
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class CatalogController < ApplicationController
  
  def librarian_view
     @response, @document = get_solr_response_for_doc_id
  end
  
   
end
