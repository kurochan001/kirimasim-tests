/*
:name: test_checker_static_scope
:description: Declarations in a checker are local to it and static, names that are not formals or checker variables resolve from the scope of the checker declaration, and the default clocking and default disable iff of that scope are inherited (IEEE 1800-2023 Section 17.2)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.2 17.7 17.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_static_scope.expected
*/
// IEEE 1800-2023 17.2: type and data declarations in a checker are local to
// the checker scope and static, the clock and disable iff contexts come from
// the scope of the checker declaration, and a name that is neither a formal
// nor a checker variable resolves from that scope. The checker below is
// declared in a module, so it sees the module function twice and the module
// default clocking and default disable iff, while its own base hides the
// module variable of the same name. Each instance has its own static count:
// u1 adds twice(100) + v at each rising clock, u2 adds twice(100) + w. v is
// 0, 1, 9, 3, 9 and 9 at the clocks at 5, 15, 25, 35 and 45, and w is 2. The
// assertion has no clock and no disable, so it is clocked by the module clock
// and disabled while the module rst is 1, which it is until 24: u1 fails at 35
// and 45, and w is never 9. The module base is unchanged.

`timescale 1ns/1ns

module test_checker_static_scope;
  logic clk = 1'b0, rst = 1'b1;
  logic [3:0] v = 4'd0, w = 4'd2;
  int base = 5;
  int h1, f1, h2, f2;

  function automatic int twice(int x);
    return 2 * x;
  endfunction

  default clocking @(posedge clk); endclocking
  default disable iff (rst);

  checker local_names(logic [3:0] sig, output int hits, output int fails);
    int base = 100;      // local to the checker and static; hides the module base
    int count = 0;
    always_ff @(posedge clk)
      count <= count + twice(base) + sig;
    assign hits = count;
    a1: assert property (sig != 4'd9) else fails = fails + 1;
  endchecker : local_names

  local_names u1(.sig(v), .hits(h1), .fails(f1));
  local_names u2(.sig(w), .hits(h2), .fails(f2));

  always #5 clk = ~clk;

  initial begin
    #2 v = 4'd1;
    #10 v = 4'd9;       // 12
    #10 v = 4'd3;       // 22
    #2 rst = 1'b0;      // 24
    #8 v = 4'd9;        // 32
    #18 $display("h1=%0d f1=%0d h2=%0d f2=%0d base=%0d", h1, f1, h2, f2, base);
    $finish;
  end
endmodule
