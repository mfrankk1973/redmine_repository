function getParentNodeChecked(parentVal)
{
  var form = document.getElementById('Entries');
  for (var i=0;i<form.elements.length;i++) 
  {
    var e = form.elements[i];   
    if(e.type=='checkbox' && e.value == parentVal) 
	return e.checked;
  }
}

function checkTree() 
{
  var form = document.getElementById('Entries');
  for (var i=0;i<form.elements.length;i++) 
  {
    var e = form.elements[i];
    if ((e.name != 'check_tree') && (e.type=='checkbox')) 
      e.checked = form.check_tree.checked;
  }
}


function checkBranch(parentId, checked)
{
  var allchecked = true;
  var has_check_tree = false;
  var form = document.getElementById('Entries');
  for (var i=0;i<form.elements.length;i++) 
  {
    var e = form.elements[i];
    if(e.type=='checkbox') 
    { 
	if(e.id == parentId)
	{
	  e.checked = !checked;
          e.click();	
        }
        allchecked = allchecked && e.checked;
        if(e.name == "check_tree") has_check_tree = true;
    }
  }
  if(has_check_tree)
    form.check_tree.checked = allchecked;
}
