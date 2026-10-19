/*
:name: test_nested_class_access
:description: A class declared inside another class is used from outside through the scope resolution operator, can use the static and local members of its outer class (non-static ones through a handle), and two outer classes may each have a nested class of the same name (IEEE 1800-2023 Section 8.23)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.23 8.18
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nested_class_access.expected
*/
// IEEE 1800-2023 §8.23: classes can nest, a nested class is public and is
// named from outside with the class scope resolution operator, as
// kt_list::entry. A nested class has the access rights of a method of its outer
// class: it uses the static members of kt_list by their simple names, even the
// local created (8.18), and reaches the non-static local secret through a
// handle to a kt_list object. kt_list::entry and kt_tree::entry are different
// classes with different members.

class kt_list;
  local static int created = 0;
  local int secret = 42;

  class entry;
    int value;
    function new(int v);
      value = v;
      created++;
    endfunction
    function int peek(kt_list owner);
      return owner.secret;
    endfunction
  endclass

  static function int count();
    return created;
  endfunction
endclass

class kt_tree;
  class entry;
    string label = "tree entry";
  endclass
endclass

module test_nested_class_access;
  // The objects are made by statements, not by initializers of the block's
  // static variables, whose order relative to other static initializers is
  // not fixed.
  initial begin
    kt_list owner;
    kt_list::entry e1, e2;
    kt_tree::entry t;
    owner = new;
    e1 = new(5);
    e2 = new(6);
    t = new;
    $display("values %0d %0d, created %0d", e1.value, e2.value, kt_list::count());
    $display("secret through a handle: %0d", e1.peek(owner));
    $display("other nested class: %s", t.label);
  end
endmodule
