/*
:name: test_buf_not_multiple_outputs
:description: buf and not gates with several outputs drive all of them from their last terminal (IEEE 1800-2023 Section 28.5)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_buf_not_multiple_outputs.expected
*/
// IEEE 1800-2023 §28.5: a buf or not gate has one input and one or more
// outputs. The input is the last terminal of the instance and all the
// terminals before it are outputs, each driven with the same value: the
// input for buf, its inverse for not.

module test_buf_not_multiple_outputs;
  logic d;
  wire a, b, c, na, nb;

  buf (a, b, c, d);
  not (na, nb, d);

  initial begin
    d = 1'b1;
    #1 $display("d=%b: buf outputs %b%b%b, not outputs %b%b", d, a, b, c, na, nb);
    d = 1'b0;
    #1 $display("d=%b: buf outputs %b%b%b, not outputs %b%b", d, a, b, c, na, nb);
  end
endmodule
