/*
:name: test_illegal_function_exported_by_two_modules
:description: A function of an interface cannot be exported by two module instances connected to it (IEEE 1800-2023 Section 25.7.4)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.7.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instances t1 and t2 are connected to the same interface instance bus and both export the function peek
:expected_stderr_regex: test_illegal_function_exported_by_two_modules\.sv:(30|38|39):
*/
// IEEE 1800-2023 §25.7.4: unlike tasks, functions cannot be exported from
// several modules, since a function always writes its result. The instance
// only is the one exporter of peek for the interface solo, which is legal;
// t1 and t2 both export peek for the interface bus.
// Oracle checks: Icarus Verilog 13.0 does not support extern subroutines in
// interfaces or subroutines in modports, and its syntax errors, which also fall
// on the lines named here, are not counted; the 5.052 release of Verilator
// reports the extern function as unsupported.

interface mfe_bus;
  int n;
  extern function int peek();
  modport tgt (export peek);
endinterface

module mfe_target(mfe_bus.tgt b);
  function int b.peek();   // the error can also be reported here
    return b.n;
  endfunction
endmodule

module test_illegal_function_exported_by_two_modules;
  mfe_bus solo (), bus ();
  mfe_target only (solo);
  mfe_target t1 (bus);   // the error can also be reported here
  mfe_target t2 (bus);   // illegal: a second export of peek
endmodule
