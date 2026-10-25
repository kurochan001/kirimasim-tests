/*
:name: test_constant_assignment_pattern_members_in_constant_contexts
:description: Assignment patterns whose members are all constant expressions (parameters, operators on them, a constant function call, a replication) give the values of parameters, which then size a vector, select a generate branch and add up in another parameter (IEEE 1800-2023 Sections 10.9.1 and 10.9.2)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.9.1 10.9.2 6.20.2 A.6.7.1 A.8.4 A.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constant_assignment_pattern_members_in_constant_contexts.expected
*/
// IEEE 1800-2023 §10.9.1, §10.9.2 with footnote 37 of A.10: an assignment
// pattern is a constant primary (A.8.4) when all its member expressions are
// constant expressions, so it can be the value of a parameter. Each member is
// evaluated as an assignment to its element or field; an index key sets that
// element, default the remaining ones, and a replication repeats its members
// over a whole dimension.
//
// With K = 3 and sq(x) = x * x (a constant function):
//   PP  = pair_t'{hi: K, lo: K + 2}            -> hi 3, lo 5, 8'h35
//   TBL = '{0: sq(K), 3: K << 1, default: -1}  -> 9 -1 -1 6
//   R3  = '{3{K + 1}}                          -> 4 4 4
//   SUM = TBL[0] + TBL[3] + R3[2]             -> 19
// The vector v is TBL[0] = 9 bits wide, and the generate if takes its first
// branch because PP.lo is 5.
//
// Icarus Verilog 13.0 reports a syntax error at the unpacked array
// parameter TBL.

module test_constant_assignment_pattern_members_in_constant_contexts;
  typedef struct packed {
    logic [3:0] hi;
    logic [3:0] lo;
  } pair_t;

  function automatic int sq(int x);
    return x * x;
  endfunction

  localparam int K = 3;
  localparam pair_t PP = pair_t'{hi: K, lo: K + 2};
  localparam int TBL [0:3] = '{0: sq(K), 3: K << 1, default: -1};
  localparam int R3 [3] = '{3{K + 1}};
  localparam int SUM = TBL[0] + TBL[3] + R3[2];

  logic [TBL[0]-1:0] v;

  if (PP.lo == 5) begin : g_five
    initial #1 $display("generate: lo is five");
  end else begin : g_other
    initial #1 $display("generate: lo is not five");
  end

  initial begin
    $display("PP=%h hi=%0d lo=%0d", PP, PP.hi, PP.lo);
    $display("TBL=%0d %0d %0d %0d", TBL[0], TBL[1], TBL[2], TBL[3]);
    $display("R3=%0d %0d %0d SUM=%0d bits(v)=%0d", R3[0], R3[1], R3[2], SUM, $bits(v));
  end
endmodule
