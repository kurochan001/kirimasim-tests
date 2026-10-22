/*
:name: test_parameterized_typedef_specializations
:description: Class parameter specializations create different typedef widths and expose explicit default parameters (IEEE 1800-2023 Section 6.25)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.25 8.25.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_parameterized_typedef_specializations.expected
*/
// IEEE 1800-2023 6.25 8.25.1: A scoped typedef uses the value parameter of its
// own specialization; accessing the default specialization uses the explicit
// empty parameter list.
// Oracle checks: Icarus Verilog 13.0 does not build this case.

module test_parameterized_typedef_specializations;
  virtual class shape #(int W = 5);
    typedef bit [W-1:0] word_t;
    static function int width(); return shape::W; endfunction
  endclass
  shape#()::word_t a;
  shape#(9)::word_t b;
  initial begin
    a = '1; b = '1;
    $display("widths=%0d,%0d params=%0d,%0d values=%h,%h", $bits(a), $bits(b),
             shape#()::width(), shape#(9)::width(), a, b);
  end
endmodule
