/*
:name: test_expr_operand_categories
:description: operands of every category form expressions, aggregates copy and compare, and the listed operators apply (IEEE 1800-2023 11.2, 11.2.2, 11.3, 11.11)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.2 11.2.2 11.3 11.11
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expr_operand_categories.expected
*/
// IEEE 1800-2023 §11.2: an expression combines operands by the rules of its
// operators, and a legal operand alone is an expression. §11.2.2: unpacked
// structures and arrays and unpacked array slices are aggregate expressions,
// which can be copied by assignment or into a subroutine argument and compared
// with equality. §11.3 and §11.11: the listed operators accept the operands of
// their tables. The test copies an unpacked structure and an unpacked array
// slice, compares both kinds of aggregate, and prints values built from a
// literal, a parameter, an array element, a bit-select, a struct member, a
// function call and a system function, then from compound and inc/dec forms.
// Icarus Verilog 13.0 does not support unpacked structs, so the expected
// output lists Verilator 5.052.

module test_expr_operand_categories;
  typedef struct {
    int x;
    int y;
  } pair_t;

  localparam int P = 5;
  pair_t ps = '{x: 4, y: 6};
  pair_t pt;
  int arr [4] = '{1, 2, 3, 4};
  int arr2 [4] = '{1, 2, 3, 4};
  int slice [2];
  logic [7:0] pv = 8'h5a;
  int n;

  function int twice(int v);
    return v * 2;
  endfunction

  function int sump(pair_t p);
    return p.x + p.y;
  endfunction

  initial begin
    n = 3;
    $display("lit=%0d param=%0d", 8'd42, P);
    $display("elem=%0d sel=%b", arr[2], pv[3]);
    pt = ps;
    $display("field=%0d,%0d arg=%0d", pt.x, pt.y, sump(pt));
    slice = arr[1:2];
    $display("slice=%0d,%0d", slice[0], slice[1]);
    $display("eq=%0d arr_eq=%0d", pt == ps, arr == arr2);
    $display("caseeq=%0d casediff=%0d", pv === 8'h5a, pv === 8'h5b);
    $display("cond=%0d", n > 2 ? 11 : 22);
    $display("func=%0d sys=%0d", twice(n), $clog2(16));
    n += 2;
    n -= 1;
    n *= 3;
    n /= 4;
    n %= 4;
    $display("compound=%0d", n);
    n++;
    ++n;
    n--;
    $display("incdec=%0d", n);
    $finish;
  end
endmodule
