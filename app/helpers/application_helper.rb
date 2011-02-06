require_dependency('vendor/plugins/blacklight/app/helpers/application_helper.rb')
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def application_name
    'Gumshoe'
  end

# Workaround for arrays; problem w/ current show code in BL's application_helper 
  def render_document_heading
    return '<h1>' + document_heading[0] + '</h1>' if document_heading.is_a? Array
    '<h1>' + document_heading + '</h1>'
  end

# BEGIN CODEBASE-266 WORKAROUND (for pre-2.8 Blacklight)
# From projectblacklight/blacklight at 9fb107db910d934b6484639df88b23009647e269
  
  def render_index_field_value args
    value = args[:value]
    value ||= args[:document].get(args[:field], :sep => nil) if args[:document] and args[:field]
    render_field_value value
  end
  
  def render_document_show_field_value args
    value = args[:value]
    value ||= args[:document].get(args[:field], :sep => nil) if args[:document] and args[:field]
    render_field_value value
  end
  
  def render_field_value value=nil
    value = [value] unless value.is_a? Array
    return value.map { |v| html_escape v }.join field_value_separator
  end

# END CODEBASE-266 WORKAROUND

  def field_value_separator # leave this in even in Blacklight 2.8+
    "<br/>\n"
  end
  
end
