/*
:name: test_vpi_named_event_relations
:description: A named event leads to its instance, its scope and its module with equal handles, a named event array leads to its instance and module and iterates its elements in vpiFullName form, and vpiArray is a Boolean property of events (IEEE 1800-2023 Section 37.27)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.27
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_named_event_relations.c
:expected_stdout: @test_vpi_named_event_relations.expected
*/
// IEEE 1800-2023 §37.27: a named event relates to its instance with
// vpiInstance, to its scope with vpiScope and to its module with vpiModule,
// and a named event array relates to its instance and to its module as well
// (the diagram of 37.27). The elements of an array are iterated with
// vpiNamedEvent, one handle for each element, from the leftmost range
// outwards (detail 3 gives the ranges, and the element names carry their
// indices). vpiFullName of an event or array is its hierarchical name
// (diagram), and vpiArray is a Boolean property (diagram, 37.16 detail 2).
// The test prints the handles' identity, names and element count only; the
// order of an iteration is not fixed, so the element names are sorted.

module nev_child;
  event e1, e2;
  event ea [0:1][4:5];
endmodule

module test_vpi_named_event_relations;
  nev_child u ();
  event ev;
  initial #1 $vt_events;
endmodule
