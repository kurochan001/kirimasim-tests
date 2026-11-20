/*
:name: test_type_this_final_class_typedef
:description: In a class declared :final in a package, type(this) can name a typedef of the class, the element type of a queue property declared with var, and the type of a local variable, and the typedef reached through the class scope is the class type itself (IEEE 1800-2023 Sections 8.11, 6.23, 8.13)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.11 6.23 8.13 6.18
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_this_final_class_typedef.expected
*/
// IEEE 1800-2023 §6.23: a type reference can be used like a type name, in a
// typedef or a declaration, a variable declared with it needs var in front,
// and type(this) is the type of the enclosing class; two type references are
// equal when their types match. §8.11: this may appear as type(this) in a
// class. §8.13: :final only forbids extending the class. §6.18: a typedef
// gives a new name to an existing type.
//
// tree_node is final and declares self_t as a typedef of type(this), the
// queue kids of type(this) handles and the method add(), which makes a child
// in a local variable of type self_t and appends it. The tree root, a (with
// the child a1) and b has 4 nodes, and the constructor counted 4 objects. The
// handle in kids[1] is assigned to a variable declared tree_node::self_t,
// which works because self_t is tree_node; the type comparison gives 1.
// Icarus Verilog 13.0 does not support :final and stops with a syntax error
// on the class header.

package test_type_this_final_pkg;
  class :final tree_node;
    typedef type(this) self_t;
    static int count;
    string name;
    var type(this) kids[$];

    function new(string n);
      name = n;
      count++;
    endfunction

    function self_t add(string n);
      self_t k = new(n);
      kids.push_back(k);
      return k;
    endfunction

    function int size();
      int s = 1;
      foreach (kids[i]) s += kids[i].size();
      return s;
    endfunction
  endclass
endpackage

module test_type_this_final_class_typedef;
  import test_type_this_final_pkg::*;
  tree_node root, a;
  tree_node::self_t second;

  initial begin
    root = new("root");
    a = root.add("a");
    void'(a.add("a1"));
    void'(root.add("b"));
    second = root.kids[1];
    $display("size=%0d count=%0d", root.size(), tree_node::count);
    $display("kids: %s %s, grandchild: %s", root.kids[0].name, second.name,
             root.kids[0].kids[0].name);
    $display("self_t is tree_node: %0d", type(tree_node::self_t) == type(tree_node));
  end
endmodule
