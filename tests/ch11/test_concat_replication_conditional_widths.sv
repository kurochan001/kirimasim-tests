/*
:name: test_concat_replication_conditional_widths
:description: Observe sum and replication widths and self-determined conditional controls
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.6.1 11.8.1 20.6.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_concat_replication_conditional_widths.expected
*/
// IEEE 11.6.1: inner sums remain four bits even in a 64-bit target;
// concatenation adds component widths and replication multiplies them.
// A 64-bit nonzero condition does not enlarge nine-bit branches and is
// not truncated to its zero low bit. IEEE 11.8.1 makes selections and
// concatenations unsigned even when the complete source is signed.
module test_concat_replication_conditional_widths;
  logic [3:0] a = 4'hf;
  logic [8:0] b = 9'h101;
  logic [63:0] condition = 64'h100;
  logic [63:0] joined, repeated;
  logic signed [3:0] negative = -1;
  logic [15:0] selected_bit, selected_part, concatenated;
  initial begin
    joined = {a+a,b};
    repeated = {3{a+a,b}};
    $display("widths=%0d %0d values=%h %h",
             $bits({a+a,b}), $bits({3{a+a,b}}), joined, repeated);
    $display("conditional_bits=%0d %0d values=%h %h",
             $bits(condition ? a : b), $bits(condition ? b : a),
             condition ? a : b, condition ? b : a);
    selected_bit = negative[0];
    selected_part = negative[3:0];
    concatenated = {negative};
    $display("unsigned_selection=%h %h %h", selected_bit, selected_part, concatenated);
    $finish;
  end
endmodule
