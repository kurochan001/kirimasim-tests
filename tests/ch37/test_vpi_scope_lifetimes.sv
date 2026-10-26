/*
:name: test_vpi_scope_lifetimes
:description: vpiAutomatic of a module, interface, program or package instance gives the default lifetime of the variables of its tasks and functions, and of a class definition and class typespec gives the automatic lifetime of its methods (IEEE 1800-2023 Section 37.3.7)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.3.7 37.32 6.21 8.6 23.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_scope_lifetimes.c
:expected_stdout: @test_vpi_scope_lifetimes.expected
*/
// IEEE 1800-2023 §37.3.7: vpiAutomatic is FALSE for a static object and TRUE
// for a non-static one. On an instance of a module, program, interface or
// package it gives the default lifetime of the variables of the tasks and
// functions declared in it; the default is static (§6.21), and the automatic
// qualifier on the declaration changes it. On a class definition or class
// typespec it gives the default lifetime of the variables of the class's
// declared tasks and functions, which is automatic because a class method has
// an automatic lifetime (§8.6). The test declares one static and one automatic
// module, interface, program and package, and a class, and prints vpiAutomatic
// for each instance or declaration and for the class's method.

module automatic sl_auto;
endmodule

module sl_static;
endmodule

interface automatic il_auto;
endinterface

interface il_static;
endinterface

program automatic pl_auto;
endprogram

program pl_static;
endprogram

package automatic pk_auto;
endpackage

package pk_static;
endpackage

module test_vpi_scope_lifetimes;
  class C;
    int prop;

    task m;
      int local_v;
    endtask
  endclass

  sl_auto u_ma();
  sl_static u_ms();
  il_auto u_ia();
  il_static u_is();
  pl_auto u_pa();
  pl_static u_ps();
  C c;

  initial begin
    c = new;
    #1 $vt_auto;
  end
endmodule
