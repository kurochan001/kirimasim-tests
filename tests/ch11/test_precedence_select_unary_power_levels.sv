/*
:name: test_precedence_select_unary_power_levels
:description: selects, member and package references bind before unary operators, every unary operator binds before **, ** binds before * / %, and ** groups from the left (IEEE 1800-2023 Section 11.3.2)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_precedence_select_unary_power_levels.expected
*/
// IEEE 1800-2023 §11.3.2, Table 11-2: the first row ((), [], ::, .) has the
// highest precedence, the unary operators the next, then **, then * / %.
// Operators of one row have the same precedence, and ** associates left.
// Each line prints an expression without parentheses, chosen so that the
// other grouping gives a different value:
// - A select, a member or a package reference is taken before the unary
//   operator in front of it: in an 8-bit context ~v[0] extends the one bit
//   v[0] to 8 bits and then inverts it (254), where inverting v first and
//   selecting bit 0 would give 0; -s.f negates the member f (251, not the
//   low nibble of -s, 11). Parentheses group first, and m[1][0] selects the
//   row first (4, not m[0][1] = 2).
// - Each unary operator applies to its operand before **: -a3 ** 2 is
//   (-3)**2 = 9, not -9; the reduction operators give a 1-bit operand of
//   ** (whose result has the size of its left operand), which differs from
//   reducing the power (for example ^a5 ** 2 is 0, ^(25) would be 1).
//   ++i and j-- need a variable operand, so they can only group first.
// - ** is applied before * / % on either side of it, and 2 ** 3 ** 2 is
//   (2**3)**2 = 64, not 2**9 = 512.

package p_prec;
  localparam logic [3:0] K = 4'b0011;
endpackage

module test_precedence_select_unary_power_levels;
  logic [7:0] v = 8'b0000_0001;
  struct packed { logic [3:0] hi; logic [3:0] f; } s = 8'h05;
  int m [2][3] = '{'{1, 2, 3}, '{4, 5, 6}};
  logic [7:0] r8;
  int a3 = 3, a1 = 1, am1 = -1, a2 = 2, a0 = 0, a5 = 5, n1 = -1;
  int i = 3, j = 3;

  initial begin
    r8 = ~v[0];
    $display("r8 = ~v[0] = %0d", r8);
    r8 = -s.f;
    $display("r8 = -s.f = %0d", r8);
    r8 = ~p_prec::K;
    $display("r8 = ~p_prec::K = %0d", r8);
    $display("(2 + 3) * 4 = %0d", (2 + 3) * 4);
    $display("m[1][0] = %0d", m[1][0]);
    $display("-a3 ** 2 = %0d", -a3 ** 2);
    $display("~a1 ** 2 = %0d", ~a1 ** 2);
    $display("!a3 ** 0 = %0d", !a3 ** 0);
    $display("&am1 ** 2 = %0d", &am1 ** 2);
    $display("~&am1 ** 2 = %0d", ~&am1 ** 2);
    $display("|a2 ** n1 = %0d", |a2 ** n1);
    $display("~|a0 ** 0 = %0d", ~|a0 ** 0);
    $display("^a5 ** 2 = %0d", ^a5 ** 2);
    $display("~^a5 ** 2 = %0d", ~^a5 ** 2);
    $display("^~a5 ** 2 = %0d", ^~a5 ** 2);
    $display("2 ** 3 * 3 = %0d", 2 ** 3 * 3);
    $display("3 * 2 ** 3 = %0d", 3 * 2 ** 3);
    $display("64 / 2 ** 3 = %0d", 64 / 2 ** 3);
    $display("20 %% 3 ** 2 = %0d", 20 % 3 ** 2);
    $display("2 ** 3 ** 2 = %0d", 2 ** 3 ** 2);
    $display("3 ** 2 ** 0 = %0d", 3 ** 2 ** 0);
    $display("++i ** 2 = %0d", ++i ** 2);
    $display("j-- ** 2 = %0d", j-- ** 2);
  end
endmodule
