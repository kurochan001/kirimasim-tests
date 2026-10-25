/*
:name: test_checker_body_procedural_and_generate_items
:description: A checker body may hold initial, always_comb, always_ff and final procedures, a concurrent assert, cover and immediate assertion, a continuous assignment, and loop, conditional and generate-region constructs with an elaboration severity task in a branch that is not elaborated (IEEE 1800-2023 Sections 17.5, 17.7 and A.1.8)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.5 17.7 A.1.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_body_procedural_and_generate_items.expected
*/
// IEEE 1800-2023 17.5, 17.7 and A.1.8: a checker_or_generate_item may be a
// checker_or_generate_item_declaration, an initial, an always, a final, an
// assertion item, a continuous assignment, or a checker_generate_item, and a
// checker_generate_item may be a loop generate, a conditional generate, a
// generate region or an elaboration severity system task.
//   - initial sets the output side to 7,
//   - always_comb drives comb_out with the complement of d,
//   - always_ff adds 1 to cnt at each rising edge while rst_n is 1,
//   - the concurrent assert adds 1 to pass_n at each rising edge where d is
//     sampled 1, the cover and the immediate assertion have no printed
//     effect,
//   - the continuous assignment drives reg_out with d,
//   - the generate region, the loop generate and its conditional generate
//     each drive one checker variable, and gen_sum adds them,
//   - the elaboration severity task is in an if (0) branch, so it is not
//     elaborated and does not end the run; a tool that elaborated it would
//     stop before the last line,
//   - final prints the value of d and pass_n at the end of the run.
// With two rising edges at 2 and 6 and d = 1, cnt and pass_n are 2,
// comb_out is 0, reg_out is 1 and gen_sum is 1 + 0 + 0 = 1.
//
// Icarus Verilog 13.0 has no checkers. Verilator 5.052 does not accept this
// body.

checker cb_items (
  input  logic clk,
  input  logic d,
  input  logic rst_n,
  output int cnt,
  output int pass_n,
  output int side,
  output logic comb_out,
  output logic reg_out,
  output int gen_sum
);
  genvar g;
  logic gv0, gv1, gr_out;

  initial side = 7;

  always_comb comb_out = ~d;

  always_ff @(posedge clk)
    if (rst_n) cnt <= cnt + 1;

  a_ok: assert property (@(posedge clk) d) pass_n = pass_n + 1;
  c_ok: cover property (@(posedge clk) d);
  initial assert (d inside {1'b0, 1'b1});

  assign reg_out = d;

  generate
    if (1) begin : gr
      assign gr_out = d ^ 1'b1;
    end
  endgenerate

  for (g = 0; g < 2; g++) begin : gl
    if (g == 0) begin : g0
      assign gv0 = d;
    end else begin : g1
      assign gv1 = ~d;
    end
  end

  if (0) begin : gsev
    $fatal(1, "checker generate branch not elaborated");
  end

  assign gen_sum = gv0 + gv1 + gr_out;

  final $display("checker final: d=%b pass_n=%0d", d, pass_n);
endchecker

module test_checker_body_procedural_and_generate_items;
  logic clk = 1'b0;
  logic d = 1'b1;
  logic rst_n = 1'b1;
  int cnt = 0, pass_n = 0, side;
  logic comb_out, reg_out;
  int gen_sum;

  cb_items u_ci (.clk(clk), .d(d), .rst_n(rst_n), .cnt(cnt), .pass_n(pass_n),
                 .side(side), .comb_out(comb_out), .reg_out(reg_out),
                 .gen_sum(gen_sum));

  initial begin
    #2 clk = 1'b1;
    #2 clk = 1'b0;
    #2 clk = 1'b1;
    #2 $display("cnt=%0d pass=%0d comb=%b reg=%b gen=%0d side=%0d",
                cnt, pass_n, comb_out, reg_out, gen_sum, side);
  end
endmodule
