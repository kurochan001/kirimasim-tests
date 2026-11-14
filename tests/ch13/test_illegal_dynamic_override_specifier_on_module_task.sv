/*
:name: test_illegal_dynamic_override_specifier_on_module_task
:description: a task declared in a module, which is not a class method, cannot have a dynamic override specifier (IEEE 1800-2023 Section 13.3)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module task report is declared with the dynamic override specifier :initial
:expected_stderr_regex: ^(?![^\n]*(?i:unsupported|not supported|not implemented|syntax error))[^\n]*test_illegal_dynamic_override_specifier_on_module_task\.sv:36:(?:\d+:)?[^\n]*(?i:override|specifier|initial|method)
*/
// IEEE 1800-2023 §13.3, footnote 25 of Syntax 13-1: the grammar of a task
// declaration has a place for dynamic override specifiers, but they shall be
// legal only on method declarations in a class that is not an interface
// class. The class base_c declares its virtual task show with :initial,
// which is legal (§8.20); the module declares its own task report with the
// same specifier, which is not a method.
// Without the specifier on report the design is legal and prints
// "method 1" and then "task 2".
// The expected error names the specifier or the rule: a tool that does not
// parse the specifiers at all stops with a syntax error, which does not show
// that it knows the rule, so the pattern leaves out errors that say syntax
// error or unsupported.
// Icarus Verilog 13.0 does not parse dynamic override specifiers, and the
// 5.054 release of Verilator accepts the design.

module test_illegal_dynamic_override_specifier_on_module_task;
  class base_c;
    virtual task :initial show(input int a);
      $display("method %0d", a);
    endtask
  endclass

  task :initial report(input int a);   // illegal: not a class method
    $display("task %0d", a);
  endtask

  base_c b;

  initial begin
    b = new;
    b.show(1);
    report(2);
  end
endmodule
