/*
:name: test_parameterized_function_width_truncation
:description: Static functions in different class specializations operate at their respective parameterized widths (IEEE 1800-2023 Section 13.8)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_parameterized_function_width_truncation.expected
*/
// IEEE 1800-2023 13.8: The same arithmetic method truncates at each
// specialization width; a shared implementation must not reuse another
// specialization width.
// Oracle checks: Icarus Verilog 13.0 does not build this case.

module test_parameterized_function_width_truncation;
  virtual class arithmetic #(int W);
    static function bit [W-1:0] add_one(bit [W-1:0] value);
      return value + 1'b1;
    endfunction
  endclass
  initial $display("wrap=%0d wide=%0d", arithmetic#(4)::add_one(15),
                   arithmetic#(8)::add_one(15));
endmodule
