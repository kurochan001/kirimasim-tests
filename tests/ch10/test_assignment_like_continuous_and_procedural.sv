/*
:name: test_assignment_like_continuous_and_procedural
:description: continuous assignments to a net and to variables and blocking and nonblocking procedural assignments are assignment-like contexts, so an assignment pattern without a type takes the type of the target and braces with an unpacked array target are an unpacked array concatenation (IEEE 1800-2023 Section 10.8)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.8 10.9 10.10
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assignment_like_continuous_and_procedural.expected
*/
// IEEE 1800-2023 §10.8: a continuous assignment (§10.3) and a procedural
// assignment, blocking or nonblocking (§10.4), are assignment-like contexts.
// In such a context an assignment pattern without a type takes the type of
// the target (§10.9), and braces whose target is an unpacked array are an
// unpacked array concatenation (§10.10); with a vector target the same
// braces are a vector concatenation (§10.10.2).
// pair_t is a packed structure of two 8-bit members. As a pattern,
// '{three, four} gives each int to one member, so hi = 3 and lo = 4; read as
// a vector concatenation it would be 64 bits cut to 16 (hi = 0, lo = 4).
//   - Continuous assignments put a pattern on a net and on a variable of type
//     pair_t, and braces on a fixed-size unpacked array.
//   - The procedure assigns patterns with a blocking and with a nonblocking
//     assignment, and braces to a queue, to a dynamic array and, with a
//     nonblocking assignment, to a fixed-size array; the element counts show
//     that each item of the braces became one element.
//   - The vector vec takes the same three bytes as one 24-bit value.
// Everything is printed at time 1, after all the assignments.
// Icarus Verilog 13.0 stops with an internal error at the nonblocking
// assignment of braces to the fixed-size array, which is legal (§10.10).

typedef struct packed {
  logic [7:0] hi;
  logic [7:0] lo;
} pair_t;

module test_assignment_like_continuous_and_procedural;
  int three = 3, four = 4;

  wire pair_t net_pair;
  pair_t var_pair;
  logic [7:0] cont_arr [3];

  assign net_pair = '{three, four};
  assign var_pair = '{four + 1, three + 3};
  assign cont_arr = {8'd7, 8'd8, 8'd9};

  pair_t blk, nba;
  logic [7:0] q [$];
  logic [7:0] dyn [];
  logic [7:0] fixed [3];
  logic [23:0] vec;

  initial begin
    blk = '{three + 7, four + 7};
    nba <= '{three * 4, four * 4};
    q = {8'd1, 8'd2, 8'd3};
    dyn = {8'd4, 8'd5};
    fixed <= {8'd10, 8'd11, 8'd12};
    vec = {8'd1, 8'd2, 8'd3};
    #1;
    $display("continuous net: hi=%0d lo=%0d", net_pair.hi, net_pair.lo);
    $display("continuous variable: hi=%0d lo=%0d", var_pair.hi, var_pair.lo);
    $display("continuous array: %0d %0d %0d", cont_arr[0], cont_arr[1], cont_arr[2]);
    $display("blocking: hi=%0d lo=%0d", blk.hi, blk.lo);
    $display("nonblocking: hi=%0d lo=%0d", nba.hi, nba.lo);
    $display("queue: size=%0d %0d %0d %0d", q.size(), q[0], q[1], q[2]);
    $display("dynamic array: size=%0d %0d %0d", dyn.size(), dyn[0], dyn[1]);
    $display("nonblocking array: %0d %0d %0d", fixed[0], fixed[1], fixed[2]);
    $display("vector: %h", vec);
  end
endmodule
