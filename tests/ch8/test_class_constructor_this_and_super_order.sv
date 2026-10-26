/*
:name: test_class_constructor_this_and_super_order
:description: this selects the current object's property, super.new runs before the subclass body, and a constructor consumes no simulation time
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.7 8.11 8.15 8.17
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_constructor_this_and_super_order.expected
*/
// IEEE 1800-2023 8.7: new is a function without an explicit return type and
// cannot block or consume simulation time. 8.11: this is the handle of the
// object used to invoke the method and disambiguates properties with the same
// name. 8.15 and 8.17: an explicit super.new call is the first executable
// statement of the constructor, so the superclass body runs before the
// subclass body. The test gives the base and the derived class a property of
// the same name, compares the two ids, records the constructor order in a
// string, and reads the simulation time before and after new.

class base;
  int id;
  string order;

  function new(int id);
    this.id = id;
    order = "B";
  endfunction

  function int base_id();
    return id;
  endfunction
endclass

class child extends base;
  int id;

  function new(int id, int base_id);
    super.new(base_id);
    this.id = id;
    order = {order, "C"};
  endfunction
endclass

module test_class_constructor_this_and_super_order;
  child c;
  int t_before;
  int t_after;

  initial begin
    t_before = $time;
    c = new(2, 1);
    t_after = $time;
    $display("child_id=%0d base_id=%0d", c.id, c.base_id());
    $display("order=%s", c.order);
    $display("t_before=%0d t_after=%0d", t_before, t_after);
  end
endmodule
