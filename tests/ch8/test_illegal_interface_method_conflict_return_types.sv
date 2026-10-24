/*
:name: test_illegal_interface_method_conflict_return_types
:description: one method cannot implement two interface methods of the same name with different return types (IEEE 1800-2023 Section 8.26.6.1)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26.6.1 8.26.6 8.20
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: code_c implements num_if and text_if, whose methods code return int and string, with one method code
:expected_stderr_regex: test_illegal_interface_method_conflict_return_types\.sv:(46|47):
*/
// IEEE 1800-2023 §8.26.6.1: when a class has to implement several methods of
// the same name, one method prototype or implementation shall provide the
// implementation for all of them, and be a valid virtual method override
// (8.20) of each. If no single method can, as when the return types differ,
// the class is in error. pair_c resolves the conflict of two methods size
// with the same prototype; code_c cannot satisfy both code methods. A tool
// can report the method or the class.
// Icarus Verilog 13.0 does not support interface classes, and Verilator 5.052
// accepts the design.

interface class num_if;
  pure virtual function int code();
  pure virtual function int size();
endclass

interface class text_if;
  pure virtual function string code();
endclass

interface class size_if;
  pure virtual function int size();
endclass

class pair_c implements num_if, size_if;
  virtual function int code();
    return 1;
  endfunction
  virtual function int size();
    return 2;
  endfunction
endclass

class code_c implements num_if, text_if;   // (or reported here)
  virtual function int code();   // illegal: cannot also override text_if::code
    return 3;
  endfunction
  virtual function int size();
    return 4;
  endfunction
endclass

module test_illegal_interface_method_conflict_return_types;
  pair_c p = new;
  initial $display("%0d %0d", p.code(), p.size());
endmodule
