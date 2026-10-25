/*
:name: test_star_sensitivity_contexts_and_exclusions
:description: @* is sensitive to every net and variable read in its statement, on right-hand sides, as function arguments, in case expressions and case items, in conditional expressions and as indices of a written variable, also when the statement writes them too, but not to variables that are only written (IEEE 1800-2023 Section 9.4.2.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_star_sensitivity_contexts_and_exclusions.expected
*/
// IEEE 1800-2023 §9.4.2.2: @* adds to its event expression every net and
// variable identifier that appears in the statement it controls: on the
// right-hand side of assignments, in subroutine calls, in case and
// conditional expressions, as an index on the left-hand side and in case
// item expressions. It leaves out identifiers that appear only in timing
// controls and those that appear only as the variable written on the
// left-hand side of an assignment.
//
// The always @* block writes t1, y, z, w and arr[idx]. It reads a, the net
// wn, f (only as an argument of fn), t1 (which it also writes), sel (case
// expression), ci (case item), b (in a case branch), en (condition of ?:)
// and idx (index of the written arr). Each of these changes in turn, one
// time unit apart, and the number of runs goes up by one each time. Then
// another process writes y and an element of arr, which the block only
// writes: the count stays the same and the written values stay. Whether
// the block also runs at time 0, when the net wn gets its first value, is
// left open by the standard, so the runs are counted from time 1.

module test_star_sensitivity_contexts_and_exclusions;
  logic [7:0] a = 8'd1, b = 8'd2, f = 8'd4, sel = 8'd0, ci = 8'd5, idx = 8'd0, src = 8'd7;
  logic en = 1'b0;
  wire [7:0] wn = src;
  logic [7:0] t1, y, z, w;
  logic [7:0] arr [0:3] = '{8'd0, 8'd0, 8'd0, 8'd0};
  int n = 0, n0;

  function automatic logic [7:0] fn(logic [7:0] x);
    return x + 8'd1;
  endfunction

  always @* begin
    n++;
    t1 = a & 8'h0f;
    y = t1 + fn(f);
    case (sel)
      ci: z = b;
      default: z = 8'd0;
    endcase
    w = en ? 8'd1 : 8'd2;
    arr[idx] = wn;
  end

  task automatic show(string what);
    #1 $display("%-6s runs=%0d y=%0d z=%0d w=%0d arr=%0d,%0d,%0d,%0d", what, n - n0, y, z, w,
                arr[0], arr[1], arr[2], arr[3]);
  endtask

  initial begin
    #1 n0 = n;
    a = 8'd3;
    show("a");
    src = 8'd8;
    show("wn");
    f = 8'd10;
    show("f");
    t1 = 8'd50;
    show("t1");
    sel = 8'd6;
    show("sel");
    ci = 8'd6;
    show("ci");
    b = 8'd9;
    show("b");
    en = 1'b1;
    show("en");
    idx = 8'd2;
    show("idx");
    y = 8'd99;
    show("y");
    arr[3] = 8'd77;
    show("arr[3]");
  end
endmodule
