/*
:name: test_illegal_dynamic_override_specifier_in_interface_class
:description: a method prototype of an interface class cannot have a dynamic override specifier, although the same prototype is legal in a virtual class (IEEE 1800-2023 Section 13.3)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the pure virtual task run of the interface class runner_if is declared with the dynamic override specifier :initial
:expected_stderr_regex: ^(?![^\n]*(?i:unsupported|not supported|not implemented|syntax error))[^\n]*test_illegal_dynamic_override_specifier_in_interface_class\.sv:35:(?:\d+:)?[^\n]*(?i:override|specifier|initial|method|interface)
*/
// IEEE 1800-2023 §13.3, footnote 25 of Syntax 13-1: dynamic override
// specifiers shall be legal only on method declarations in a class that is
// not an interface class. The grammar of a method prototype (A.2.7) has a
// place for them, and the virtual class base_c uses it: its pure virtual
// task run is declared with :initial, which is legal (§8.20). The interface
// class runner_if declares the same prototype. The class impl_c implements
// runner_if and is the only class that is constructed.
// Without the specifier in runner_if the design is legal and prints "run".
// The expected error names the specifier or the rule: a tool that does not
// parse the specifiers at all stops with a syntax error, which does not show
// that it knows the rule, so the pattern leaves out errors that say syntax
// error or unsupported.
// Icarus Verilog 13.0 parses neither interface classes nor dynamic override
// specifiers, and the 5.054 release of Verilator accepts the design.

module test_illegal_dynamic_override_specifier_in_interface_class;
  virtual class base_c;
    pure virtual task :initial run();
  endclass

  interface class runner_if;
    pure virtual task :initial run();   // illegal: a method of an interface class
  endclass

  class impl_c implements runner_if;
    virtual task run();
      $display("run");
    endtask
  endclass

  impl_c c;

  initial begin
    c = new;
    c.run();
  end
endmodule
