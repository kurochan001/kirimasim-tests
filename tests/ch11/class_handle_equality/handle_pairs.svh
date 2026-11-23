class parent_t;
endclass

class child_t extends parent_t;
endclass

parent_t parent_handle;
child_t child_handle;

initial begin
  show("both_null");

  parent_handle = new;
  show("null_child_base_object");

  parent_handle = null;
  child_handle = new;
  show("child_object_null_parent");

  parent_handle = child_handle;
  show("same_object");

  // The base-typed handle still refers to the first child.
  child_handle = new;
  show("two_child_objects");

  parent_handle = new;
  show("child_and_base_objects");
end
