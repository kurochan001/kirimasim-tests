/*
:name: test_vpi_class_internal_scopes
:description: A class definition gives its enclosing scope and its method scopes, a class typespec gives its method scopes and each leads back to the typespec, and a class object gives its method scopes (IEEE 1800-2023 Sections 37.31, 37.32 and 37.33)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.31 37.32 37.33 37.12 8.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_class_internal_scopes.c
:expected_stdout: @test_vpi_class_internal_scopes.expected
*/
// IEEE 1800-2023 §37.31: a class definition has a one-to-one relation to its
// scope with the untagged scope access type (37.31 diagram), here the module
// that declares it, and a one-to-many relation to scopes with the tag
// vpiInternalScope. §37.32: a class typespec has the same vpiInternalScope
// relation to scopes, and each of those scopes gives the class typespec with
// the untagged class typespec access type (37.32 diagram). §37.33: a class
// object has a one-to-many relation to scopes with vpiInternalScope (37.33
// diagram). The task and function declared in the class are the scopes it
// contains (37.12), and they are printed sorted by name.

`timescale 1ns/1ns

module test_vpi_class_internal_scopes;
  class cs_c;
    int x;
    function int f();
      return x;
    endfunction
    task t();
      x = 1;
    endtask
  endclass

  cs_c obj;

  initial begin
    obj = new;
    #1 $vt_classscope;
  end
endmodule
