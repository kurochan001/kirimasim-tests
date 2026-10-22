/*
:name: test_interface_partial_default_argument
:description: A partial virtual implementation can complete its remaining method in a subclass while preserving constant defaults (IEEE 1800-2023 Section 8.26.7)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.26.7 8.26.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_partial_default_argument.expected
*/
// IEEE 1800-2023 8.26.7 8.26.8: The intermediate virtual class explicitly keeps
// one method pure and implements the other; the concrete subclass completes the
// interface contract.
// Oracle checks: Icarus Verilog 13.0 does not build this case.

module test_interface_partial_default_argument;
  interface class api;
    pure virtual function int f(int n = 4);
    pure virtual function int g();
  endclass
  virtual class partial_impl implements api;
    virtual function int f(int n = 4); return n * 3; endfunction
    pure virtual function int g();
  endclass
  class complete_impl extends partial_impl;
    virtual function int g(); return 17; endfunction
  endclass
  complete_impl c;
  api a;
  initial begin
    c = new; a = c;
    $display("default=%0d actual=%0d remaining=%0d", a.f(), a.f(2), a.g());
  end
endmodule
