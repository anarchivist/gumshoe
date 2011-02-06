ApplicationController.before_filter do |controller|
  # # remove default jquery-ui theme.
  # controller.stylesheet_links.each do |args|
  #     args.delete_if {|a| a =~ /^|\/jquery-ui-[\d.]+\.custom\.css$/ }
  # end
  
  # add in a different jquery-ui theme, or any other css or what have you
  controller.stylesheet_links << 'gumshoe.css'
end