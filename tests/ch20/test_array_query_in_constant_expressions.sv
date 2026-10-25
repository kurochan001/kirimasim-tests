/*
:name: test_array_query_in_constant_expressions
:description: array query functions whose first argument has a fixed-size type and whose dimension is constant can be used in constant expressions: localparam values, packed and unpacked dimensions and a generate condition (IEEE 1800-2023 Section 20.7)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.7 11.2.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_query_in_constant_expressions.expected
*/
// IEEE 1800-2023 §20.7: a call of an array query function is legal in a
// constant expression when the call is legal in an expression, type() of its
// first argument is a fixed-size type, and its dimension argument, if any,
// is a constant expression. The first argument may be a variable: only its
// type is used.
// ram is a [3:0] unpacked array of a [15:8] packed type. Local parameters
// take $left of dimension 2 of ram (15), $dimensions of ram (2), $high of
// the element expression ram[0] (15) and $size of dimension 2 (8); a
// variable gets its width from $size of the type (8 bits) and an array its
// size from $size of ram (4), and a generate if chooses its branch from
// $increment of ram (1, descending).
// Icarus Verilog 13.0 does not allow the variable ram in these calls.

module test_array_query_in_constant_expressions;
  typedef logic [15:8] word_t;
  word_t ram [3:0];

  localparam int L2 = $left(ram, 2);
  localparam int DIMS = $dimensions(ram);
  localparam int HI0 = $high(ram[0]);
  localparam int SZ = $size(ram, 2);
  logic [$size(word_t) - 1:0] w;
  int arr [$size(ram)];

  if ($increment(ram) == 1) begin : g_desc
    initial #1 $display("generate: descending");
  end else begin : g_asc
    initial #1 $display("generate: ascending");
  end

  initial begin
    $display("L2=%0d DIMS=%0d HI0=%0d SZ=%0d w=%0d arr=%0d", L2, DIMS, HI0, SZ, $bits(w),
             $size(arr));
  end
endmodule
