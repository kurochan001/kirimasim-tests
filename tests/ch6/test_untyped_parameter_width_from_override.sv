/*
:name: test_untyped_parameter_width_from_override
:description: A parameter with no type or range takes the width of its overriding value (IEEE 1800-2023 Section 6.20.2)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.2 23.10.2.1 23.10.2.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_untyped_parameter_width_from_override.expected
*/
// IEEE 1800-2023 §6.20.2: a parameter declared with neither a type nor a
// range takes the type and range of its final value, after the overrides of
// the instantiation (23.10.2.1, 23.10.2.2) are applied. An integral value
// makes it a logic vector of the value's width: overridden with 3'b101 the
// parameter is 3 bits wide, with 8'ha5 it is 8 bits, and with its default,
// the unsized literal 1, it has the 32 bits of an integer.

module width_reporter #(p = 1) (output int width, output logic [31:0] value);
  assign width = $bits(p);
  assign value = p;
endmodule

module test_untyped_parameter_width_from_override;
  int w0, w1, w2;
  logic [31:0] v0, v1, v2;
  width_reporter #(3'b101) r0 (.width(w0), .value(v0));
  width_reporter #(.p(8'ha5)) r1 (.width(w1), .value(v1));
  width_reporter r2 (.width(w2), .value(v2));

  initial begin
    #1;
    $display("p = 3'b101: $bits = %0d, value = %0d", w0, v0);
    $display("p = 8'ha5: $bits = %0d, value = %0d", w1, v1);
    $display("p = 1 (default): $bits = %0d, value = %0d", w2, v2);
  end
endmodule
