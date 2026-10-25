/*
:name: test_syntax_program_instantiation_forms
:description: program instantiations without parameter values, with an ordered value for two instances in one statement and with a named value, each program computing its output from its parameter and input port (IEEE 1800-2023 Section 24.3)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.3 24.7 23.10.2 A.4.1.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_program_instantiation_forms.expected
*/
// IEEE 1800-2023 A.4.1.3: a program instantiation is the program name, an
// optional parameter value assignment, one or more instances separated by
// commas, and a semicolon. §24.3: a program is instantiated like a module,
// with its parameters set by ordered or named values (23.10.2).
//
// pg drives res with base * 10 + N. p0 keeps N = 1; #(2) applies to both p1
// and p2; p3 sets N to 9 by name. Each program then waits until time 5, so
// the module prints the outputs at time 1, before the programs end and the
// simulation finishes (24.7).

program pg #(parameter int N = 1) (input var int base, output int res);
  initial begin
    res = base * 10 + N;
    #5;
  end
endprogram

module test_syntax_program_instantiation_forms;
  int r0, r1, r2, r3;

  pg p0 (5, r0);
  pg #(2) p1 (6, r1), p2 (.base(7), .res(r2));
  pg #(.N(9)) p3 (.base(8), .res(r3));

  initial #1 $display("r0=%0d r1=%0d r2=%0d r3=%0d", r0, r1, r2, r3);
endmodule
