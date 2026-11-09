/*
:name: test_illegal_cg_extends_property_name
:description: covergroup extends shall name a covergroup of a base class, so naming a property of the base class that is not a covergroup is an error (IEEE 1800-2023 Section 19.4.1)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the extends declaration in class bad names g2, an int property of the base class and not a covergroup
:expected_stderr_regex: test_illegal_cg_extends_property_name\.sv:48:
*/
// IEEE 1800-2023 §19.4.1: covergroup extends is followed by the name of a
// base covergroup, and it is an error when no covergroup of that name has been
// defined in a base class of the enclosing class. Class base defines the
// covergroup g1 and the int property g2. Class good extends g1, which is
// legal. Class bad writes covergroup extends g2: the name exists in the base
// class, but it is a variable, not a covergroup, so there is no base
// covergroup to extend.
// Icarus Verilog 13.0 does not implement covergroups; its syntax errors fall
// on every line of the classes, including line 48, so they are no evidence for
// the rule. The 5.052 release of Verilator reports every covergroup extends,
// also the legal one, as unsupported.

module test_illegal_cg_extends_property_name;
  class base;
    int a, b;
    int g2;
    covergroup g1;
      cp: coverpoint a;
    endgroup
    function new();
      g1 = new;
    endfunction
  endclass

  class good extends base;
    covergroup extends g1;
      cb: coverpoint b;
    endgroup
    function new();
      super.new();
    endfunction
  endclass

  class bad extends base;
    covergroup extends g2;   // illegal: g2 is an int, not a covergroup
      cb: coverpoint b;
    endgroup
    function new();
      super.new();
    endfunction
  endclass

  initial begin
    $display("not reached");
  end
endmodule
