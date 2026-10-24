/*
:name: test_illegal_virtual_constructor
:description: a constructor cannot be declared virtual (IEEE 1800-2023 Section 8.7)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.7 8.20
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the constructor new of item_c is declared virtual
:expected_stderr_regex: test_illegal_virtual_constructor\.sv:30:
*/
// IEEE 1800-2023 §8.7: a constructor may be local or protected, but it shall
// not be declared static (8.10) or virtual (8.20). base_c has a local
// constructor and a virtual method, which are legal; item_c declares its
// constructor virtual.
// Icarus Verilog 13.0 accepts the virtual constructor.

class base_c;
  local function new();
  endfunction
  virtual function int id();
    return 1;
  endfunction
endclass

class item_c;
  int v;
  virtual function new();   // illegal: virtual constructor
    v = 1;
  endfunction
endclass

module test_illegal_virtual_constructor;
  initial $display("done");
endmodule
