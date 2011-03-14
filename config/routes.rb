ActionController::Routing::Routes.draw do |map|
  map.resources :messages, :collection => { :realtime => :get }
  map.resources :users
  map.resources :follows, :only => [:create], :collection => { :del => :post }
  map.resource :session
  map.home "/home", :controller => "messages", :action => "home"
  map.stream "/:username", :controller => "messages", :action => "user"
  map.root :controller => "messages"
end
