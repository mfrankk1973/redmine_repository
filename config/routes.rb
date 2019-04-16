ActionController::Routing::Routes.draw do |map|
     map.connect 'projects/:id/repository', :controller => 'repositories', :action => 'entries_operation'
end
