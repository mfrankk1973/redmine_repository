require 'redmine'
require 'dispatcher'
require 'repositories_controller_patch'

Redmine::Plugin.register :redmine_repository do
  name 'Redmine Repository plugin'
  author 'SaNNy'
  description 'This is a reposirory plugin for Redmine. Semgroup customization.'
  version '0.0.4'

  requires_redmine :version_or_higher => '1.1.2'
end

Redmine::AccessControl.map do |map|
	map.project_module :repository do |map|
		map.permission :operations, :repositories => [:entries_operation]
	end
end
