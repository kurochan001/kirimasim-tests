/*
:name: test_assignment_operator_row_takes_whole_right_operand
:description: the assignment operators, the dist weights := and :/ and the nonblocking <= form the row below ?: and -> in the precedence table, so each takes a whole conditional or implication as its right operand; operators of the row are combined only through parentheses (IEEE 1800-2023 Section 11.3.2)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.2 18.5.3
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assignment_operator_row_takes_whole_right_operand.expected
*/
// IEEE 1800-2023 §11.3.2, Table 11-2: = += -= *= /= %= &= ^= |= <<= >>= <<<=
// >>>=, := and :/ and the nonblocking <= share the row below ?: and -> <->,
// with no associativity, and only the concatenation row is lower. So the
// right operand of each of them is a whole expression of any higher row:
// v += c ? 3 : 4 adds the value of the conditional, and v |= p -> q ors in
// the implication. The operators of the row have no associativity, and the
// grammar never lets two of them share an operand: an assignment inside an
// expression is written in parentheses, so the last line nests them that
// way. In the constraint, each weight is a conditional expression; §18.5.3
// excludes values whose weight is zero, which fixes x at 2 and y at 5.
// With v = 10 (or -16 for the arithmetic shifts), c = 1, p = 0 and q = 0,
// each line prints the result of one operator whose right operand is a
// conditional or an implication.
// Icarus Verilog 13.0 does not support randomize.

class weights_c;
  bit c = 1'b1;
  rand int x, y;
  constraint k {
    x dist {1 := c ? 0 : 1, 2 := c ? 1 : 0};
    y dist {[4:4] :/ c ? 0 : 1, [5:5] :/ c ? 1 : 0};
  }
endclass

module test_assignment_operator_row_takes_whole_right_operand;
  bit c = 1'b1, p = 1'b0, q = 1'b0;
  int v, nb, x, y, z;
  weights_c w = new;

  initial begin
    v = 10; v = c ? 3 : 4;      $write("= %0d", v);
    v = 10; v += c ? 3 : 4;     $write(" += %0d", v);
    v = 10; v -= c ? 3 : 4;     $write(" -= %0d", v);
    v = 10; v *= c ? 3 : 4;     $write(" *= %0d", v);
    v = 10; v /= c ? 3 : 4;     $write(" /= %0d", v);
    v = 10; v %= c ? 3 : 4;     $display(" %%= %0d", v);
    v = 10; v &= c ? 6 : 1;     $write("&= %0d", v);
    v = 10; v |= c ? 5 : 0;     $write(" |= %0d", v);
    v = 10; v ^= c ? 3 : 0;     $write(" ^= %0d", v);
    v = 10; v <<= c ? 2 : 0;    $write(" <<= %0d", v);
    v = 10; v >>= c ? 1 : 0;    $display(" >>= %0d", v);
    v = -16; v <<<= c ? 1 : 0;  $write("<<<= %0d", v);
    v = -16; v >>>= c ? 2 : 0;  $display(" >>>= %0d", v);
    v = 4; v = p -> q;          $write("= -> %0d", v);
    v = 4; v |= p -> q;         $display(" |= -> %0d", v);
    nb <= c ? 7 : 8;
    #1 $display("<= %0d", nb);
    if (w.randomize()) $display(":= %0d :/ %0d", w.x, w.y);
    else $display("randomize failed");
    z = 0;
    y = 1;
    x = (y += (z = 2) * 3);
    $display("nested: x=%0d y=%0d z=%0d", x, y, z);
  end
endmodule
