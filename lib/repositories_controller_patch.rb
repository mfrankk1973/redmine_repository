require 'tree'
require_dependency 'application_controller'  
require_dependency 'repositories_controller'
require_dependency 'repository_zip'

module RepositoriesControllerPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable # послать unloadable чтобы не перегружать при разработке
    end

  end
  
  module ClassMethods    
  end
  
  module InstanceMethods	 
	 def entries_operation
	
	    selected_folders = params[:folders].nil? ? [] : params[:folders]
	    selected_files = params[:files].nil? ? [] : params[:files]
	    		    	    
	    if selected_folders.empty? && selected_files.empty?
	      redirect_to :action => "show", :id => @project, :path => @path
	      return
	    end	   
	    	    	   
	    # make a selected files and folders tree
	    selected_tree = Tree::TreeNode.new(".", "root")
            selected_files.each do |file| 
		folder = Pathname.new(file).dirname.to_s
		selected_tree_node = selected_tree
		if !folder.match(/^\.+$/)
		    folder.split("/").each do 
		       if selected_tree_node[folder].nil?
		     	  selected_tree_node =  selected_tree_node.add(Tree::TreeNode.new(folder, "folder"))
		       else 
		          selected_tree_node = selected_tree_node[folder]
		       end
		    end
		    selected_tree_node << Tree::TreeNode.new(file, "file") 	
		else
		    selected_tree << Tree::TreeNode.new(file, "file") 	   
		end
	    end
  	    selected_folders.each do |folder|
		selected_tree_node = selected_tree
		folder.split("/").each do	  
  		  if selected_tree_node[folder].nil?
		     selected_tree_node =  selected_tree_node.add(Tree::TreeNode.new(folder, "folder"))
		  else 
		     selected_tree_node = selected_tree_node[folder]
		  end
                end
	    end              
	    

	    begin
	      if !params[:email_entries].blank?
	        email_entries(selected_tree)
              else
	        download_entries(selected_tree)
	      end
            rescue => e
               flash[:warning] = l(:error_in_getting_files) +  " (" + e.message + ")"
               redirect_to :action => "show", :id => @project, :path => @path
	    end
	 end

	 def download_entries(selected_tree)

	    zip = RepositoryZip.new	   
	    zip_entries(zip, selected_tree)
	    	    
	    send_file(zip.finish, 
	      :filename => filename_for_content_disposition(@project.name + "-" + DateTime.now.strftime("%y%m%d%H%M%S") + ".zip"),
	      :type => "application/zip", 
	      :disposition => "attachment")
	  ensure
	    zip.close unless zip.nil? 
	  end
	    
	  def zip_entries(zip, selected_tree)	               
            selected_tree.children.each do |node|
	        if node.content == "file"
		   zip.add_file(node.name, @repository.cat(node.name, @rev))
		else
                   zip.add_folder(node.name)
  		   if node.hasChildren?
                     # add selected subfolders
		     zip_entries(zip, node)
                   else
                     # add all subfolders with files		
		     entries = @repository.entries(node.name, @rev)
                     entries.each do |entry| 
			node << Tree::TreeNode.new(entry.path, entry.is_dir? ? "folder" : "file")
		     end
		   end
		   zip_entries(zip, node)
                end
            end             
	    zip
	  end
  end # of InstaceMethods
end # of module

RepositoriesController.send(:include, RepositoriesControllerPatch)
