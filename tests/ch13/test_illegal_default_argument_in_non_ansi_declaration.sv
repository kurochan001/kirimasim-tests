/*
:name: test_illegal_default_argument_in_non_ansi_declaration
:description: default argument values are allowed only in ANSI-style declarations (IEEE 1800-2023 Section 13.5.3)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the non-ANSI declaration of the argument b of the task t gives it a default value
:expected_stderr_regex: test_illegal_default_argument_in_non_ansi_declaration\.sv:29:
*/
// IEEE 1800-2023 §13.5.3: default argument values shall only be used with
// ANSI-style declarations of the arguments. f declares its default in its
// argument list, which is legal; t declares its arguments in its body, the
// non-ANSI style, and gives b a default value there.
// The grammar allows "= expression" there (list_of_tf_variable_identifiers),
// and the rule of 13.5.3 makes it illegal. Icarus Verilog 13.0 reports a syntax
// error on this line, which does not show that rule, and Verilator 5.052
// accepts the design.

module test_illegal_default_argument_in_non_ansi_declaration;
  function int f(input int a, input int b = 3);
    return a + b;
  endfunction
  task t;
    input int a;
    input int b = 3;   // illegal
    $display("%0d", a + b);
  endtask
  initial begin
    $display("%0d", f(1));
    t(1, 2);
  end
endmodule
