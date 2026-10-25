/*
:name: test_illegal_final_pure_virtual
:description: A pure virtual method cannot be declared :final (IEEE 1800-2023 Section 8.20)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.20 8.21
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a pure virtual method is declared :final
:expected_stderr_regex: test_illegal_final_pure_virtual\.sv:21:
*/
// IEEE 1800-2023 §8.20: it shall be illegal to specify final in a pure virtual
// method declaration (§8.21), which a subclass has to override.
// Icarus Verilog 13.0 does not support this construct of IEEE 1800-2023, so
// the error it reports on that line does not count. The design is accepted
// by Verilator 5.052 (docs/simulator-differences.md).

virtual class test_illegal_final_pure_virtual_base;
  pure virtual function :final int id();   // illegal: final on a pure virtual method
endclass

class test_illegal_final_pure_virtual_derived extends test_illegal_final_pure_virtual_base;
  virtual function int id();
    return 1;
  endfunction
endclass

module test_illegal_final_pure_virtual;
  test_illegal_final_pure_virtual_derived d = new;
  initial $display("id=%0d", d.id());
endmodule
