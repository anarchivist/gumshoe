class UnsupportedMarcFormatType < RuntimeError; end


# This is a document extension meant to be mixed into a
# Blacklight::Solr::Document class, such as SolrDocument. It provides support
# for restoration of MARC data (xml or binary) from a Solr stored field, and
# then provides various transformations/exports of that Marc via the included
# Blacklight::Solr::Document::MarcExport module.
#
# This extension would normally be registered using 
# Blacklight::Solr::Document#use_extension.  eg:
#
# SolrDocument.use_extension( Blacklight::Solr::Document::Marc ) { |document| my_logic_for_document_has_marc?( document ) }
#
# This extension also expects a :marc_source_field and :marc_format_type to
# be registered with the hosting classes extension_parameters. In an initializer
# or other startup code:
# SolrDocument.extension_paramters[:marc_source_field] = "name_of_solr_stored_field"
# SolrDocument.extension_parameters[:marc_format_type] = :marc21 # or :marcxml
module Blacklight::Solr::Document::Marc
  
  include Blacklight::Solr::Document::MarcExport # All our export_as stuff based on to_marc. 

  def self.extended(document)
    # Register our exportable formats, we inherit these from MarcExport    
    Blacklight::Solr::Document::MarcExport.register_export_formats( document )
  end

  # DEPRECATED. Here for legacy purposes, but use to_marc instead. Or
  # internally, use the protected _marc_helper method to get the
  # (somewhat confusingly named)  Blacklight::Marc::Document helper object.
  #
  # This method gets attached to a SolrDocument.
  # it uses the marc_source_field and marc_format_type
  # class attributes to create the Blacklight::Marc::Document instance.
  # Only returns a Blacklight::Marc::Document instance if
  # the self.class.marc_source_field key exists.
  def marc
    warn "[DEPRECATION] aDocument.marc is deprecated.  Please use aDocument.respond_to?(:to_marc) / aDocument.respond_to?(:marc),  or aDocument.exports_as.keys.include?(:some_format) / aDocument.export_as(:some_format) instead."

    _marc_helper
  end  

  # ruby-marc object
  def to_marc
    @_ruby_marc_obj ||= load_marc
  end


  protected
  def marc_source
    @_marc_source ||= fetch(_marc_source_field)
  end

  def load_marc
      case _marc_format_type.to_s
        when 'marcxml'
          records = MARC::XMLReader.new(StringIO.new( fetch(_marc_source_field) )).to_a
          return records[0]
        when 'marc21'
          return MARC::Record.new_from_marc( fetch(_marc_source_field) )          
        else
          raise UnsupportedMarcFormatType.new("Only marcxml and marc21 are supported.")
      end      
   end


  
  def _marc_helper
    @_marc_helper ||= (
      Blacklight::Marc::Document.new fetch(_marc_source_field), _marc_format_type )
  end

  def _marc_source_field    
    self.class.extension_parameters[:marc_source_field]
  end

  def _marc_format_type
        #TODO: Raise if not present
    self.class.extension_parameters[:marc_format_type]    
  end
  
end