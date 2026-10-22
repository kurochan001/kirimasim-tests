/*
:name: test_interface_class_shared_method_implementation
:description: One implementation satisfies matching pure virtual methods from two interface classes (IEEE 1800-2023 Section 8.26.1)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.26.1 8.26.6.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_class_shared_method_implementation.expected
*/
// IEEE 1800-2023 8.26.1 8.26.6.1: Two unrelated interface prototypes of the
// same signature can share one implementing method, called through both
// interface handles.
// Oracle checks: Icarus Verilog 13.0 does not build this case.

module test_interface_class_shared_method_implementation;
  interface class read_a;
    pure virtual function int read();
  endclass
  interface class read_b;
    pure virtual function int read();
  endclass
  class impl implements read_a, read_b;
    virtual function int read(); return 23; endfunction
  endclass
  impl obj;
  read_a a;
  read_b b;
  initial begin
    obj = new; a = obj; b = obj;
    $display("interfaces=%0d,%0d", a.read(), b.read());
  end
endmodule
