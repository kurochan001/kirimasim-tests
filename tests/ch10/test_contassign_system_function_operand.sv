/*
:name: test_contassign_system_function_operand
:description: A continuous assignment is evaluated again when an operand inside a system function call changes (IEEE 1800-2023 Section 10.3.2)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3.2 11.7 20.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_contassign_system_function_operand.expected
*/
// IEEE 1800-2023 §10.3.2: a continuous assignment is evaluated again whenever an
// operand of its right-hand side changes. An operand passed to a system function
// such as $signed, $unsigned (11.7), $countones or $isunknown (20.9) is such an
// operand too. Before p is first written it is x, so $isunknown(p) is 1.

module test_contassign_system_function_operand;
  logic [1:0] p;
  logic signed [1:0] vs;  wire signed [1:0] ws;
  logic [3:0] vu;
  logic signed [3:0] ve;
  logic [2:0] cnt;
  logic unk;
  logic signed [1:0] vc;   // control: no system call
  assign vs = $signed(p);
  assign ws = $signed(p);
  assign vu = $unsigned(p);
  assign ve = $signed(p) + 4'sd0;
  assign cnt = $countones(p);
  assign unk = $isunknown(p);
  assign vc = p;
  int errors = 0;

  task automatic check(string what, logic [3:0] got, logic [3:0] exp);
    if (got !== exp) begin
      $display("WRONG %s: got %b expected %b", what, got, exp);
      errors++;
    end
  endtask

  initial begin
    #1;
    check("unknown at start", {3'b0, unk}, 4'b0001);
    p = 2'b10;
    #1;
    // a signed 2-bit value sign-extends to the 4-bit argument of check()
    check("A variable <= $signed(p)", vs, 4'b1110);
    check("B net <= $signed(p)", ws, 4'b1110);
    check("C variable <= $unsigned(p)", vu, 4'b0010);
    check("D variable <= $signed(p) + 4'sd0", ve, 4'b1110);
    check("E $countones(p)", {1'b0, cnt}, 4'b0001);
    check("F $isunknown(p)", {3'b0, unk}, 4'b0000);
    check("ctl variable <= p", vc, 4'b1110);
    p = 2'b01;
    #1;
    check("G $signed(p) after a second change", vs, 4'b0001);
    check("H $countones(p) after a second change", {1'b0, cnt}, 4'b0001);
    p = 2'b11;
    #1;
    check("I $countones(p) = 2", {1'b0, cnt}, 4'b0010);
    if (errors == 0) begin
      $display("TEST PASSED: continuous assignment through a system function call");
    end else begin
      $display("TEST FAILED: %0d errors", errors);
    end
    $finish;
  end
endmodule
