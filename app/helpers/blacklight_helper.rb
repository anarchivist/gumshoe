module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  def version
    '0.2.0-alpha'
  end

  def application_name
    'Gumshoe ' + version
  end

# Workaround for arrays; problem w/ current show code in BL's application_helper 
  def render_document_heading
    return '<h1>' + document_heading[0] + '</h1>' if document_heading.is_a? Array
    '<h1>' + document_heading + '</h1>'
  end
  
  def field_value_separator # leave this in even in Blacklight 2.8+
    "<br/>\n"
  end

end
