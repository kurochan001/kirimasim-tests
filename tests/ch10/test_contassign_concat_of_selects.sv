/*
:name: test_contassign_concat_of_selects
:description: Continuous assignments whose left-hand side is a concatenation of bit-selects and part-selects of nets (IEEE 1800-2023 Section 10.3.2)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3.2 11.4.12 11.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_contassign_concat_of_selects.expected
*/
// IEEE 1800-2023 §10.3.2, §11.4.12, §11.5.1: the left-hand side of a continuous
// assignment can be a concatenation of bit-selects and part-selects. Each select
// receives its own slice of the right-hand side, from the left, so two
// assignments that each drive some bits of a vector together drive all of it,
// and a concatenation that names two halves in swapped order swaps them.

module test_contassign_concat_of_selects;
  logic [11:0] src = 12'hff4;
  wire [11:0] w, c;
  assign {w[3], w[1:0]} = 3'b000;                 // A: two concatenations that together
  assign {w[11:4], w[2]} = {src[11:4], src[2]};   //    drive every bit of w
  wire [7:0] s;
  assign {s[3:0], s[7:4]} = 8'h5a;                // B: swap: s[3:0]=5, s[7:4]=a
  wire [7:0] x;
  assign {x[0 +: 4], x[7 -: 4]} = src[7:0];       // C: indexed selects: x[3:0]=f, x[7:4]=4
  logic [3:0] whole;
  wire [3:0] y;
  assign {whole, y[3:2], y[1:0]} = {src[3:0], src[11:8]};  // D: a whole signal and selects
  assign c[11:4] = src[11:4];                     // control: one select per assignment
  assign c[3] = 1'b0;
  assign c[2] = src[2];
  assign c[1:0] = 2'b00;
  logic co;
  logic [2:0] sm;
  assign {co, sm} = src[3:0] + 4'd5;              // control: whole signals only
  int errors = 0;

  task automatic check(string what, logic [11:0] got, logic [11:0] exp);
    if (got !== exp) begin
      $display("WRONG %s: got %h expected %h", what, got, exp);
      errors++;
    end
  endtask

  initial begin
    #1;
    check("A w (two concatenation targets)", w, 12'hff4);
    check("B s (swapped halves)", s, 12'h0a5);
    check("C x (indexed selects)", x, 12'h04f);
    check("D whole", whole, 12'h004);
    check("D y", y, 12'h00f);
    check("ctl c (one select per assignment)", c, 12'hff4);
    check("ctl {co, sm}", {co, sm}, 12'h009);
    src = 12'h3c9;
    #1;
    check("A w after src changes", w, 12'h3c0);
    check("C x after src changes", x, 12'h09c);   // x[3:0] = src[7:4] = c, x[7:4] = src[3:0] = 9
    check("D y after src changes", y, 12'h003);
    if (errors == 0) begin
      $display("TEST PASSED: concatenation of selects on the left of a continuous assignment");
    end else begin
      $display("TEST FAILED: %0d errors", errors);
    end
    $finish;
  end
endmodule
