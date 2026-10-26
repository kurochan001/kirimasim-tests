/*
:name: test_parameter_and_const_lifetime
:description: parameter, localparam and specparam are elaboration-time constants used in declaration widths, while a const is a runtime constant with the lifetime of its scope
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_parameter_and_const_lifetime.expected
*/
// IEEE 1800-2023 6.20: parameter, localparam and specparam are elaboration-time
// parameter constants, and const denotes a runtime constant whose value does
// not change during its lifetime. P and L size the vectors pv and lv, and SP
// is read in a display, so all three are elaborated before the run. SC is a
// static const and keeps 7. In the automatic function f, the const AC is
// initialized from the automatic av at each call, so the two calls keep their
// own 11 and 21; a tool that made AC static, or that required its initializer
// to be constant, prints 11 11 or cannot elaborate the call.

module test_parameter_and_const_lifetime;
  parameter int P = 4;
  localparam int L = P * 2;
  specparam SP = 3;
  logic [P-1:0] pv;
  logic [L-1:0] lv;
  const int SC = 7;

  function automatic int f(int seed);
    automatic int av = seed;
    const int AC = av + 1;
    return AC;
  endfunction

  initial begin
    pv = '1;
    lv = '1;
    $display("bits=%0d %0d sp=%0d sc=%0d", $bits(pv), $bits(lv), SP, SC);
    $display("ac=%0d %0d", f(10), f(20));
  end
endmodule
