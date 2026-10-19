/*
:name: test_propagated_operand_sign
:description: A signed operand of an unsigned expression is zero-extended to the width of the context (IEEE 1800-2023 Section 11.8.2)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.8.2 11.8.1 11.4.11 12.5 6.24.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_propagated_operand_sign.expected
*/
// IEEE 1800-2023 §11.8.1, §11.8.2: an expression is unsigned when any of its
// operands is unsigned, and its type and width are then passed down to every
// context-determined operand. An operand is sign-extended only when the type
// passed down is signed, so a signed operand of an unsigned expression is
// zero-extended. This holds for the arithmetic operators, for a conditional
// operator with one unsigned branch (11.4.11) and for a case expression
// (12.5). A cast keeps the sign of its operand (6.24.1), and an assignment
// extends the right-hand side by its own sign.

module test_propagated_operand_sign;
  logic [7:0] u = 8'hFF;
  logic signed [7:0] s = -1;
  logic [31:0] u32 = 1;
  int m = -1;
  reg signed in4;
  logic signed [15:0] r;
  logic [15:0] q;
  logic [63:0] x;
  logic [7:0] y;
  int hit;
  wire signed [15:0] w = u + s;
  int errors = 0;

  task automatic check(string what, longint got, longint exp);
    if (got !== exp) begin
      $display("WRONG %s = %0d, expected %0d", what, got, exp);
      errors++;
    end
  endtask

  initial begin
    in4 = 1;
    #1;
    // s is zero-extended to 16 bits (255) because u + s is unsigned
    r = u + s; check("A1 u + s", r, 510);
    r = u - s; check("A2 u - s", r, 0);
    r = u * s; check("A3 u * s", r, -511);
    q = s + u; check("A4 s + u (unsigned target)", q, 510);
    check("A5 continuous u + s", w, 510);
    x = u32 + m; check("A6 u32 + int (64-bit)", x, 64'h1_0000_0000);
    // 1'h0 is unsigned, so the conditional expression is unsigned
    y = 0 ? 1'h0 : in4; check("B1 y = 0 ? 1'h0 : in4", y, 1);
    case (0 ? 1'h0 : in4)
      5'b0101:   hit = 1;
      8'b000001: hit = 2;
      default:   hit = 3;
    endcase
    check("B2 case (0 ? 1'h0 : in4)", hit, 2);
    // Controls
    r = s + 8'sh01; check("ctl signed s + 8'sh01", r, 0);
    y = 0 ? 1'sb0 : in4; check("ctl y = 0 ? 1'sb0 : in4", y, 255);
    q = u + 16'(s); check("ctl u + 16'(s)", q, 254);
    q = s; check("ctl q = s", q, 65535);
    r = u; check("ctl r = u", r, 255);
    r = $signed(u) + s; check("ctl $signed(u) + s", r, -2);
    if (errors == 0) begin
      $display("TEST PASSED: operands extend by the sign of the expression");
    end else begin
      $display("TEST FAILED: %0d errors", errors);
    end
    $finish;
  end
endmodule
