/*
:name: test_illegal_modport_name_of_enclosing_interface
:description: a modport of a nested interface cannot name a signal that the enclosing interface declares (IEEE 1800-2023 Section 25.5)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.5 25.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: modport view of the nested interface en_inner names shared, which only the enclosing interface en_outer declares
:expected_stderr_regex: test_illegal_modport_name_of_enclosing_interface\.sv:27:
*/
// IEEE 1800-2023 §25.5: every name in a modport shall be declared by the
// interface that declares the modport, not by an interface that encloses
// it. §25.3 allows an interface declaration inside another one. The nested
// interface en_inner declares own and has the modport view, which names own,
// as it may, and shared, which belongs to the enclosing interface en_outer.
// Neither Icarus Verilog 13.0 nor the 5.052 release of Verilator supports
// an interface declared and instantiated inside another interface.

interface en_outer;
  logic shared;

  interface en_inner;
    logic own;
    modport view (input own, input shared);   // illegal
  endinterface

  en_inner inner ();
endinterface

module test_illegal_modport_name_of_enclosing_interface;
  en_outer o ();
endmodule
