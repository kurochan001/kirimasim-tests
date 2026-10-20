/*
:name: test_illegal_interface_class_unqualified_type
:description: A class that implements an interface class does not inherit its typedefs, so it cannot use one without the class scope (IEEE 1800-2023 Section 8.26.3)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the class uses the typedef of the interface class it implements without naming the interface class
:expected_stderr_regex: test_illegal_interface_class_unqualified_type\.sv:27:
*/
// IEEE 1800-2023 §8.26.3: typedefs and parameters of an interface class are
// inherited by interface classes that extend it but not by classes that
// implement it, so inside meter the name level_t is not declared. Icarus
// Verilog 13.0 does not support interface classes, so the syntax errors it
// reports there, as on most other lines, do not count.

module test_illegal_interface_class_unqualified_type;
  interface class gauge_if;
    typedef byte level_t;
    pure virtual function level_t level();
  endclass

  class meter implements gauge_if;
    virtual function level_t level();   // illegal: level_t is not inherited
      return 3;
    endfunction
  endclass
endmodule
