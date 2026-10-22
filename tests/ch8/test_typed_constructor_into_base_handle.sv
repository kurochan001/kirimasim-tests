/*
:name: test_typed_constructor_into_base_handle
:description: A typed constructor builds a derived object directly into a base handle (IEEE 1800-2023 Section 8.8)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_typed_constructor_into_base_handle.expected
*/
// IEEE 1800-2023 8.8: The typed new selects the derived constructor and its
// arguments independently of the base type of the destination handle.
// Oracle checks: Icarus Verilog 13.0 does not reproduce the clause-derived
// output.

module test_typed_constructor_into_base_handle;
  class base;
    int value;
    virtual function int read(); return value; endfunction
  endclass
  class child extends base;
    function new(int n); value = n + 10; endfunction
    virtual function int read(); return value * 2; endfunction
  endclass
  base b;
  initial begin
    b = child::new(7);
    $display("value=%0d virtual=%0d", b.value, b.read());
  end
endmodule
