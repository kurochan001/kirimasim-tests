/*
:name: test_case_constant_expression_runtime_items
:description: A case statement whose case expression is a constant compares that value against item expressions computed at run time and takes the first item that equals it (IEEE 1800-2023 Section 12.5.2)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5.2 12.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_case_constant_expression_runtime_items.expected
*/
// IEEE 1800-2023 §12.5.2: the case expression can be a constant expression;
// its value is compared against the case item expressions, which need not
// be constant (12.5), so the item that matches depends on run-time values.
//
// The first case has the parameter TARGET (12) as its case expression and
// the sum, product and difference of the variables x and y as items. The
// second has the literal 1'b0 and the bits of a 3-bit variable as items, so
// it finds the highest bit that is 0. Each is run with several values;
// when two items equal the constant, the first one is taken.

module test_case_constant_expression_runtime_items;
  parameter int TARGET = 12;
  int x, y;
  logic [2:0] m;
  string took;

  task automatic arith(int a, int b);
    x = a;
    y = b;
    case (TARGET)
      x + y: took = "sum";
      x * y: took = "product";
      x - y: took = "difference";
      default: took = "none";
    endcase
    $display("TARGET=%0d x=%0d y=%0d: %s", TARGET, x, y, took);
  endtask

  task automatic zero_bit(logic [2:0] value);
    m = value;
    case (1'b0)
      m[2]: took = "bit 2";
      m[1]: took = "bit 1";
      m[0]: took = "bit 0";
      default: took = "no zero bit";
    endcase
    $display("1'b0 m=%b: %s", m, took);
  endtask

  initial begin
    arith(5, 7);
    arith(3, 4);
    arith(20, 8);
    arith(12, 0);
    arith(1, 1);
    zero_bit(3'b011);
    zero_bit(3'b101);
    zero_bit(3'b110);
    zero_bit(3'b111);
  end
endmodule
