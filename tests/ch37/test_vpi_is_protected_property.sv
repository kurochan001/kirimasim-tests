/*
:name: test_vpi_is_protected_property
:description: Every object has the property vpiIsProtected, which is false for objects that are not in protected code, and vpiType can be read for any object (IEEE 1800-2023 Section 37.3.6)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.3.6 38.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_is_protected_property.c
:expected_stdout: @test_vpi_is_protected_property.expected
*/
// IEEE 1800-2023 §37.3.6: every object has the Boolean property vpiIsProtected,
// TRUE only when it represents protected code, and vpiType can always be read.
// Nothing in this design is protected, so vpi_get (38.16) gives 0 for the
// module, a net, a variable and a task.

module test_vpi_is_protected_property;
  wire w;
  int v;

  task t;
  endtask

  initial #1 $vt_protect;
endmodule
