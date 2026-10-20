/*
:name: test_illegal_implements_forward_typedef
:description: A class cannot implement an interface class that is only declared by a forward typedef at that point (IEEE 1800-2023 Section 8.26.4)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the class implements an interface class known only through a forward typedef
:expected_stderr_regex: test_illegal_implements_forward_typedef\.sv:23:
*/
// IEEE 1800-2023 §8.26.4: a class shall not implement a forward typedef of an
// interface class; the interface class has to be declared before it is
// implemented or extended. Icarus Verilog 13.0 does not support interface
// classes, so the syntax errors it reports there, as on most other lines, do
// not count.

module test_illegal_implements_forward_typedef;
  typedef interface class later_if;

  class early implements later_if;   // illegal: later_if is not declared yet
    virtual function int get();
      return 1;
    endfunction
  endclass

  interface class later_if;
    pure virtual function int get();
  endclass
endmodule
