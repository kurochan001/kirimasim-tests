/*
:name: test_extern_method_scoped_return_type
:description: An out of block method can use a class typedef as its return type and omit a prototype default (IEEE 1800-2023 Section 8.24)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.24
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_extern_method_scoped_return_type.expected
*/
// IEEE 1800-2023 8.24: The return type is qualified by the class scope, while
// the default argument remains available from the in-class declaration.
// Oracle checks: Icarus Verilog 13.0 does not build this case. The 5.052
// release does not build this case.

module test_extern_method_scoped_return_type;
  class packet;
    typedef bit [7:0] octet_t;
    extern function octet_t make(int n = 11);
  endclass
  function packet::octet_t packet::make(int n);
    return octet_t'(n + 1);
  endfunction
  packet p;
  initial begin
    p = new;
    $display("default=%0d supplied=%0d", p.make(), p.make(254));
  end
endmodule
