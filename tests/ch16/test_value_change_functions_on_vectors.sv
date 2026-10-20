/*
:name: test_value_change_functions_on_vectors
:description: $rose and $fell of a vector or part-select look only at its least significant bit, while $changed and $stable look at the whole value (IEEE 1800-2023 Section 16.9.3)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.3 16.14.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_value_change_functions_on_vectors.expected
*/
// IEEE 1800-2023 §16.9.3: $rose is true when the least significant bit of
// its argument changed to 1 since the previous clock tick, and $fell when it
// changed to 0; $changed and $stable compare the whole value. For the part-
// select v[3:2] the least significant bit is v[2], so 01 -> 11 is no $rose
// although the value changed. In the always procedure the clock is inferred
// (16.14.7); at the first tick the previous value is the initial value.

module test_value_change_functions_on_vectors;
  logic clk = 0;
  logic [3:0] v = 4'b0000;

  always #5 clk = ~clk;

  always @(posedge clk)
    $display("t=%0d v=%b: rose=%b fell=%b rose(v[3:2])=%b changed=%b stable(v[1:0])=%b", $time,
             $sampled(v), $rose(v), $fell(v), $rose(v[3:2]), $changed(v), $stable(v[1:0]));

  initial begin
    @(negedge clk) v = 4'b0010;
    @(negedge clk) v = 4'b0101;
    @(negedge clk) v = 4'b1100;
    @(negedge clk) v = 4'b1000;
    @(negedge clk) $finish;
  end
endmodule
