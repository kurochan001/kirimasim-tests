/*
:name: test_vpi_named_event_array_prefix
:description: A named event array that is a non-static property of a class object leads to the class variable with vpiPrefix and has an actual, while the declaration taken from the class typespec has no prefix and no actual (IEEE 1800-2023 Section 37.61)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.61 37.32 15.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_named_event_array_prefix.c
:expected_stdout: @test_vpi_named_event_array_prefix.expected
*/
// IEEE 1800-2023 §37.61 detail 1: a named event array that is all or part of
// a non-static class property prefixed by a class variable has that class
// variable as its vpiPrefix. Detail 3: vpiHasActual is TRUE when the prefix
// has a corresponding actual at the current simulation time, and FALSE when
// the object is a non-static class property referenced relative to its class
// typespec. The test creates the class object and looks the array up through
// the object, then finds the declaration through the class typespec, and
// prints the prefix kind and name and vpiHasActual for both.

module test_vpi_named_event_array_prefix;
  class C;
    event e[2];
  endclass

  C c;

  initial begin
    c = new;
    #1 $vt_ev;
  end
endmodule
