/*
:name: test_case_common_width_and_sign
:description: The case expression and all item expressions are evaluated at the width of the longest of them, even one that never matches, and they are compared as signed only when all of them are signed (IEEE 1800-2023 Section 12.5)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_case_common_width_and_sign.expected
*/
// IEEE 1800-2023 §12.5: the case expression and all the case item
// expressions are made as long as the longest of them, not just the two
// being compared, and if any of them is unsigned all are treated as unsigned;
// they are treated as signed only if all are signed.
//
// Width: a + b with 4-bit a = 15 and b = 1 is 16 in five bits and 0 in four.
// With the items 4'd0 and 5'd17 the common width is 5, so a + b is 16 and
// matches neither item; with 4'd0 alone it is 0 and matches. An item p + q
// of 4-bit operands is evaluated at the 8 bits of the case expression.
// Sign: sn is the signed 4-bit value -1 (4'b1111). Against the signed items
// 8'sh0F and -8'sd1 it is sign-extended to 8'hFF and matches -8'sd1. Adding
// the unsigned item 4'd3, which never matches, makes every expression
// unsigned: sn is then zero-extended to 8'h0F and matches 8'sh0F instead.

module test_case_common_width_and_sign;
  logic [3:0] a, b, p, q;
  logic [7:0] wide;
  logic signed [3:0] sn;
  string took;

  initial begin
    a = 4'd15;
    b = 4'd1;
    case (a + b)
      4'd0: took = "4'd0";
      5'd17: took = "5'd17";
      default: took = "default";
    endcase
    $display("a + b, items 4'd0 5'd17: %s", took);
    case (a + b)
      4'd0: took = "4'd0";
      default: took = "default";
    endcase
    $display("a + b, item 4'd0: %s", took);

    wide = 8'd16;
    p = 4'd12;
    q = 4'd4;
    case (wide)
      4'd0: took = "4'd0";
      p + q: took = "p + q";
      default: took = "default";
    endcase
    $display("wide = 16, items 4'd0 p+q: %s", took);

    sn = -4'sd1;
    case (sn)
      8'sh0F: took = "8'sh0F";
      -8'sd1: took = "-8'sd1";
      default: took = "default";
    endcase
    $display("sn = -1, signed items: %s", took);
    case (sn)
      8'sh0F: took = "8'sh0F";
      -8'sd1: took = "-8'sd1";
      4'd3: took = "4'd3";
      default: took = "default";
    endcase
    $display("sn = -1, with unsigned item 4'd3: %s", took);
  end
endmodule
