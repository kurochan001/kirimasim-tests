/*
:name: test_type_this
:description: type(this) is the type of the enclosing class, also in a subclass, where it names the subclass (IEEE 1800-2023 Section 8.11)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.11 6.23
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_this.expected
*/
// IEEE 1800-2023 §6.23: type(this) represents the type of the enclosing class,
// and a variable declared with a type reference is preceded by var. In node it
// is node: next holds another node, and make returns one. In the subclass it is
// the subclass, so self returns a handle through which the member tag of the
// subclass can be read without a cast. §8.11: this may appear as type(this).
// Icarus Verilog 13.0 does not support type(this), and Verilator 5.052 rejects
// it in a static method (docs/simulator-differences.md).

class test_type_this_node;
  int id;
  var type(this) next;
  function new(int i);
    id = i;
  endfunction
  static function type(this) make(int i);
    var type(this) n = new(i);
    return n;
  endfunction
endclass

class test_type_this_tagged extends test_type_this_node;
  string tag = "tagged";
  function new(int i);
    super.new(i);
  endfunction
  function type(this) self();
    return this;
  endfunction
endclass

module test_type_this;
  test_type_this_node a, b;
  test_type_this_tagged t;
  initial begin
    a = test_type_this_node::make(1);
    b = test_type_this_node::make(2);
    a.next = b;
    t = new(3);
    $display("a=%0d next=%0d", a.id, a.next.id);
    $display("self: %s %0d", t.self().tag, t.self().id);
  end
endmodule
