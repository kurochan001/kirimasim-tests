/*
:name: test_illegal_virtual_interface_with_outside_reference
:description: An interface that contains a hierarchical reference to an object outside its body cannot be used in the declaration of a virtual interface, while the interface itself can be instantiated (IEEE 1800-2023 Section 25.9)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the virtual interface v is declared with vor_if, whose continuous assignment reads the module variable src through a hierarchical name
:expected_stderr_regex: test_illegal_virtual_interface_with_outside_reference\.sv:38:
*/
// IEEE 1800-2023 §25.9: an interface may contain hierarchical references to
// objects outside its body, but it shall be illegal to use such an interface
// in the declaration of a virtual interface. vor_if reads src of the top-level
// module by a hierarchical name; instantiating it is legal, and declaring a
// virtual interface of vor_if is not. The virtual interface of vor_plain_if,
// which has no such reference, is legal.
// Icarus Verilog 13.0 does not support virtual interfaces and reports
// syntax errors on their declarations, which do not count. The 5.052
// release of Verilator accepts the design.

interface vor_if;
  logic d;
  assign d = test_illegal_virtual_interface_with_outside_reference.src;
endinterface

interface vor_plain_if;
  logic d;
endinterface

module test_illegal_virtual_interface_with_outside_reference;
  logic src = 1'b1;
  vor_if a ();
  vor_plain_if b ();
  virtual vor_plain_if vp;
  virtual vor_if v;   // illegal: vor_if refers outside its body
  initial begin
    vp = b;
    #1 $display("%b", a.d);
  end
endmodule
