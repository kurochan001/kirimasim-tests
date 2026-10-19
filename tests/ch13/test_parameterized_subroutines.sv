/*
:name: test_parameterized_subroutines
:description: static methods of a parameterized class act as parameterized subroutines: each specialization, including the default one and one with a type parameter, has its own widths and types, and the methods are called through the class scope operator without an object (IEEE 1800-2023 Section 13.8)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.8 8.10 8.23 8.25 20.8.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_parameterized_subroutines.expected
*/
// IEEE 1800-2023 §13.8: parameterized tasks and functions are written as
// static methods (§8.10) of a parameterized class (§8.25), which can be
// virtual so that no object is created, and called with the class scope
// operator (§8.23) on a specialization. Here W sets the width of a value and
// IDX_W, by default $clog2(W) (§20.8.1), the width of an index; T is a type
// parameter. Each call uses the widths and types of its own specialization:
// the index of the highest set bit, a reversal of the bits, and a sum that
// wraps around in the element type.

virtual class bits_util #(int W = 8, int IDX_W = $clog2(W));
  static function logic [IDX_W-1:0] highest(logic [W-1:0] v);
    highest = '0;
    for (int i = 0; i < W; i++) if (v[i]) highest = i[IDX_W-1:0];
  endfunction

  static function logic [W-1:0] reverse(logic [W-1:0] v);
    foreach (v[i]) reverse[W-1-i] = v[i];
  endfunction
endclass

virtual class adder #(type T = int, int N = 3);
  static function T sum(T values[N]);
    sum = 0;
    foreach (values[i]) sum += values[i];
  endfunction
endclass

module test_parameterized_subroutines;
  initial begin
    $display("highest #(8): %0d, %0d bits", bits_util#(8)::highest(8'b0110_0000),
             $bits(bits_util#(8)::highest(0)));
    $display("highest #(32): %0d, %0d bits", bits_util#(32)::highest(32'h0001_0000),
             $bits(bits_util#(32)::highest(0)));
    $display("reverse default: %b", bits_util#()::reverse(8'b1100_0001));
    $display("reverse #(4): %b", bits_util#(4)::reverse(4'b0011));
    $display("sum int: %0d", adder#()::sum('{100, 100, 100}));
    $display("sum byte: %0d", adder#(byte)::sum('{100, 100, 100}));
    $display("sum shortint, 2: %0d", adder#(shortint, 2)::sum('{30000, 30000}));
  end
endmodule
