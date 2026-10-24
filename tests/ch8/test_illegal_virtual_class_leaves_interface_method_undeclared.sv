/*
:name: test_illegal_virtual_class_leaves_interface_method_undeclared
:description: a virtual class that implements an interface class has to implement or redeclare as pure each of its methods (IEEE 1800-2023 Section 8.26.7)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26.7 8.26
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the virtual class bad_part_c implements two_if but neither implements nor redeclares its method second
:expected_stderr_regex: test_illegal_virtual_class_leaves_interface_method_undeclared\.sv:(41|45):
*/
// IEEE 1800-2023 §8.26.7: a virtual class that implements an interface class
// shall, for each method prototype of the interface class, either provide an
// implementation or declare the prototype again with pure (or inherit one,
// 8.26). good_part_c implements first and declares second again as pure,
// which is legal; bad_part_c says nothing about second. A tool can report the
// class or its end.
// Icarus Verilog 13.0 does not support interface classes, and Verilator 5.052
// accepts the design.

interface class two_if;
  pure virtual function int first();
  pure virtual function int second();
endclass

virtual class good_part_c implements two_if;
  virtual function int first();
    return 1;
  endfunction
  pure virtual function int second();
endclass

class full_c extends good_part_c;
  virtual function int second();
    return 2;
  endfunction
endclass

virtual class bad_part_c implements two_if;   // illegal: second is missing
  virtual function int first();
    return 1;
  endfunction
endclass   // (or reported here)

module test_illegal_virtual_class_leaves_interface_method_undeclared;
  full_c f = new;
  initial $display("%0d %0d", f.first(), f.second());
endmodule
