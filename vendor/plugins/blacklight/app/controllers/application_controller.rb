#
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
#
class ApplicationController < ActionController::Base

  before_filter :default_html_head # add JS/stylesheet stuff
  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user_session, :current_user
  after_filter :discard_flash_if_xhr

  def user_class; User; end

  helper_method [:request_is_for_user_resource?]#, :user_logged_in?]
  #before_filter [:set_current_user, :restrict_user_access]

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '200c1e5f25e610288439b479ef176bbd'

  layout :choose_layout

  # test for exception notifier plugin
  def error
    raise RuntimeError, "Generating a test error..."
  end

  #############
  # Display-related methods.
  #############

  # before filter to set up our default html HEAD content. Sub-class
  # controllers can over-ride this method, or instead turn off the before_filter
  # if they like. See:
  # http://api.rubyonrails.org/classes/ActionController/Filters/ClassMethods.html
  # for how to turn off a filter in a sub-class and such.
  def default_html_head
    stylesheet_links << ['yui', 'jquery/ui-lightness/jquery-ui-1.8.1.custom.css', 'application', {:plugin=>:blacklight, :media=>'all'}]

    javascript_includes << ['jquery-1.4.2.min.js', 'jquery-ui-1.8.1.custom.min.js', 'blacklight', 'application', 'accordion', { :plugin=>:blacklight } ]
  end


  # An array of strings to be added to HTML HEAD section of view.
  # See ApplicationHelper#render_head_content for details.
  def extra_head_content
    @extra_head_content ||= []
  end
  helper_method :extra_head_content

  # Array, where each element is an array of arguments to
  # Rails stylesheet_link_tag helper. See
  # ApplicationHelper#render_head_content for details.
  def stylesheet_links
    @stylesheet_links ||= []
  end
  helper_method :stylesheet_links

  # Array, where each element is an array of arguments to
  # Rails javascript_include_tag helper. See
  # ApplicationHelper#render_head_content for details.
  def javascript_includes
    @javascript_includes ||= []
  end
  helper_method :javascript_includes


  protected

    # Returns a list of Searches from the ids in the user's history.
    def searches_from_history
      session[:history].blank? ? [] : Search.find(session[:history]) rescue []
    end

    #
    # Controller and view helper for determining if the current url is a request for a user resource
    #
    def request_is_for_user_resource?
      request.env['PATH_INFO'] =~ /\/?users\/?/
    end

    #
    # If a param[:no_layout] is set OR
    # request.env['HTTP_X_REQUESTED_WITH']=='XMLHttpRequest'
    # don't use a layout, otherwise use the "application.html.erb" layout
    #
    def choose_layout
      'application' unless request.xml_http_request? || ! params[:no_layout].blank?
    end

    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end
    
    def discard_flash_if_xhr
      flash.discard if request.xhr?
    end

end

