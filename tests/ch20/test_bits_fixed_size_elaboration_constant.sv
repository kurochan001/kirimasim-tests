/*
:name: test_bits_fixed_size_elaboration_constant
:description: $bits of a fixed-size type or variable is an elaboration-time constant that can set the range of a typedef, the value of a localparam, the width of a variable, the size of an unpacked array and a generate condition (IEEE 1800-2023 Section 20.6.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.6.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bits_fixed_size_elaboration_constant.expected
*/
// IEEE 1800-2023 §20.6.2: $bits of a fixed-size data type can be used as an
// elaboration-time constant, so it can appear in the declarations of other
// types, variables and nets.
// $bits of an 8-bit packed structure sets the range [8:1] of a typedef, $bits
// of an unpacked array type of three bytes gives a localparam of 24, $bits of
// int sets the width of a variable to 32, $bits of a 4-state 12-bit vector
// variable sets the size of an unpacked array to 12 and $bits of shortint
// selects a generate branch. A net is declared with a width from $bits too.

module test_bits_fixed_size_elaboration_constant;
  typedef struct packed {
    logic [2:0] tag;
    bit [4:0] val;
  } rec_t;
  typedef byte three_t [3];
  typedef bit [$bits(rec_t):1] rec_bits_t;
  localparam int THREE_BITS = $bits(three_t);

  logic [11:0] twelve;
  rec_bits_t rb;
  logic [$bits(int) - 1:0] wv;
  int arr [$bits(twelve)];
  wire [$bits(byte) - 1:0] nw;

  if ($bits(shortint) == 16) begin : g16
    initial #1 $display("generate: shortint is 16 bits");
  end else begin : g_other
    initial #1 $display("generate: shortint is not 16 bits");
  end

  initial begin
    $display("rec_bits=%0d [%0d:%0d] three=%0d wv=%0d", $bits(rb), $left(rb), $right(rb),
             THREE_BITS, $bits(wv));
    $display("arr size=%0d net=%0d", $size(arr), $bits(nw));
  end
endmodule
