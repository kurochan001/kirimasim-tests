/*
:name: test_constant_builtin_method_calls_at_elaboration
:description: a built-in method call is a constant expression evaluated at elaboration when its identifier and arguments are constant, and also for a variable identifier when the result does not depend on the variable's value (IEEE 1800-2023 Section 11.2.1)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.2.1 6.16 6.19.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constant_builtin_method_calls_at_elaboration.expected
*/
// IEEE 1800-2023 §11.2.1: a call of a built-in method whose value depends
// only on its arguments and on the value of its identifier, without side
// effects, is a constant built-in method call when the identifier and the
// arguments are constant expressions. When the value does not depend on the
// identifier's value, constant arguments are enough, even for a variable.
// Such calls in constant expressions are evaluated at elaboration.
// The string parameters S = "hello" and NS = "42" are constant, so the
// string methods (§6.16) S.len() (5), S.toupper() ("HELLO"), S.substr(1, 3)
// ("ell"), S.getc(4) (111, the code of "o") and NS.atoi() (42) are constant;
// S.len() also sizes the packed dimension of wl (5 bits). ev is a variable
// of an enumeration holding GREEN (5), but the enumeration methods (§6.19.5)
// ev.num() (3), ev.first() (RED, 2) and ev.last() (BLUE, 9) depend only on
// the type, so they are constant too; ev.num() also chooses the generate
// branch g_three. All results are localparams, printed at time 0.
// Icarus Verilog 13.0 does not support the toupper, substr and getc methods.

module test_constant_builtin_method_calls_at_elaboration;
  typedef enum logic [3:0] { RED = 4'd2, GREEN = 4'd5, BLUE = 4'd9 } color_t;
  localparam string S = "hello";
  localparam string NS = "42";
  color_t ev = GREEN;
  localparam int P_LEN = S.len();
  localparam string P_UP = S.toupper();
  localparam string P_SUB = S.substr(1, 3);
  localparam int P_GETC = S.getc(4);
  localparam int P_ATOI = NS.atoi();
  localparam int P_NUM = ev.num();
  localparam color_t P_FIRST = ev.first();
  localparam color_t P_LAST = ev.last();
  logic [P_LEN-1:0] wl;

  if (ev.num() == 3) begin : g_three
    localparam int K = 33;
  end else begin : g_other
    localparam int K = 0;
  end

  initial begin
    $display("constant identifier: %0d %s %s %0d %0d, $bits(wl) = %0d", P_LEN, P_UP, P_SUB,
             P_GETC, P_ATOI, $bits(wl));
    $display("variable identifier: %0d %s %0d %s %0d, generate: %0d", P_NUM, P_FIRST.name(),
             P_FIRST, P_LAST.name(), P_LAST, g_three.K);
    $display("ev = %s", ev.name());
  end
endmodule
