/*
:name: test_shift_power_self_determined_count
:description: Keep shift and power result widths independent of the count width and sign
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.6.1 11.4.3 11.4.10 20.6.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_shift_power_self_determined_count.expected
*/
// IEEE 11.6.1: all five result widths follow the four-bit base, not
// the 64-bit count. Count 16 must not truncate to four-bit zero. Under
// 11.4.10 a signed four-bit -1 means unsigned shift count 15, whereas
// the self-determined signed exponent -1 still means a reciprocal.
module test_shift_power_self_determined_count;
  logic [3:0] base = 4'd2;
  logic [63:0] count = 64'd2;
  logic [31:0] one = 1, two = 2;
  logic signed [3:0] minus_one = -1;
  logic [31:0] high = 32'h80000000;
  initial begin
    $display("bits=%0d %0d %0d %0d %0d", $bits(base<<count), $bits(base>>count),
             $bits(base<<<count), $bits(base>>>count), $bits(base**count));
    $display("values=%h %h %h %h %h",
             base<<count, base>>count, base<<<count, base>>>count, base**count);
    count = 64'd16;
    $display("wide_count=%h %h", base<<count, base>>count);
    $display("signed_count=%h negative_exponent=%h unsigned_shift=%h",
             one<<minus_one, two**minus_one, high>>>minus_one);
    $finish;
  end
endmodule
