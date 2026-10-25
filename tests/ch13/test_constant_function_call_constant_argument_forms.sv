/*
:name: test_constant_function_call_constant_argument_forms
:description: Constant function calls whose arguments are constant expressions of several kinds (a parameter expression, another constant function call, a default argument, an argument of a package function and of a static class method) are evaluated with the parameter values of each instance and set a localparam, a vector width and a generate branch (IEEE 1800-2023 Section 13.4.3)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.3 A.8.2 A.8.4 A.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constant_function_call_constant_argument_forms.expected
*/
// IEEE 1800-2023 §13.4.3 with footnote 41 of A.10: a call of a constant
// function is a constant function call, evaluated at elaboration, when all its
// arguments are constant expressions; the function may be local to the
// design element, in a package, or a static method of a class local to it.
// The parameters it uses are those of the calling instance.
//
// In cf_unit, with parameter N:
//   W  = up_log2(N * 4)              (smallest r with 2**r >= N * 4)
//   S  = scale(up_log2(N))           (nested call; m defaults to 3)
//   B  = cf_pkg::add_base(N)         (package function, BASE = 10)
//   T  = cf_util::twice(N + 1)       (static method of a class in the module)
//   g  = generate branch chosen by scale(N, 2) > 20, KIND 1 or 0
// u5 (N = 5):   W 5, S 9, B 15, T 12, scale(5, 2) = 10  -> KIND 0
// u17 (N = 17): W 7, S 15, B 27, T 36, scale(17, 2) = 34 -> KIND 1
// The vector bus has W bits.
//
// Icarus Verilog 13.0 reports a syntax error at the call of the static class
// method in the value of T; with that call replaced, it prints the expected
// values.

package cf_pkg;
  localparam int BASE = 10;

  function automatic int add_base(int x);
    return x + BASE;
  endfunction
endpackage

module cf_unit #(parameter int N = 5);
  class cf_util;
    static function int twice(int x);
      return 2 * x;
    endfunction
  endclass

  function automatic int up_log2(int v);
    int r = 0;
    while ((1 << r) < v) r++;
    return r;
  endfunction

  function automatic int scale(int x, int m = 3);
    return x * m;
  endfunction

  localparam int W = up_log2(N * 4);
  localparam int S = scale(up_log2(N));
  localparam int B = cf_pkg::add_base(N);
  localparam int T = cf_util::twice(N + 1);

  logic [W-1:0] bus;

  if (scale(N, 2) > 20) begin : g
    localparam int KIND = 1;
  end else begin : g
    localparam int KIND = 0;
  end
endmodule

module test_constant_function_call_constant_argument_forms;
  cf_unit u5 ();
  cf_unit #(.N(17)) u17 ();

  initial begin
    $display("u5: W=%0d S=%0d B=%0d T=%0d bits=%0d kind=%0d", u5.W, u5.S, u5.B, u5.T,
             $bits(u5.bus), u5.g.KIND);
    $display("u17: W=%0d S=%0d B=%0d T=%0d bits=%0d kind=%0d", u17.W, u17.S, u17.B, u17.T,
             $bits(u17.bus), u17.g.KIND);
  end
endmodule
