/*
:name: test_dpi_context_scope_switch
:description: svGetScope in a context import names the instance scope of the import declaration, an export called from the import runs in that scope without svSetScope, and svSetScope to the other instance's scope makes the export run there until the old scope is set back (IEEE 1800-2023 Sections H.6.5 and H.9.1, 35.5.3)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 H.6.5 H.9.1 35.5.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_context_scope_switch.c
:expected_stdout: @test_dpi_context_scope_switch.expected
*/
// IEEE 1800-2023 §H.6.5 and H.9.1: svGetScope in the C code of an import
// returns the svScope of the instance scope of that import declaration. An
// export called from the import runs in that scope when the import has not
// called svSetScope, and in the scope that svSetScope selected when it has,
// until the previous scope is set back. Two instances of one module that
// declare the same import and export the same function each have their own
// export instance and context.
//
// Each instance calls the imports from its own initial procedure, so the call
// site of each import is the instance that declares it. u1 starts at time 0
// and u2 at time 1; their steps are 10 time units apart, so the order of the
// lines is fixed. c_note stores what svGetScope returns. c_step with mode 0
// calls the export sv_unit_id without svSetScope, which gives the identifier
// of the instance whose scope is active. With mode 2 it sets the scope stored
// for u2, calls the export, and sets the old scope back, which the next call
// with mode 0 confirms. With mode 1 it compares the two stored scope names
// with the hierarchical names of the two instances.

module unit #(parameter int ID = 0, parameter int START = 0);
  import "DPI-C" context function void c_note(input int slot);
  import "DPI-C" context function void c_step(input int slot, input int mode);
  export "DPI-C" function sv_unit_id;

  function int sv_unit_id();
    return ID;
  endfunction

  initial begin
    #(START) c_note(ID);
    #10 c_step(ID, 0);
    #10 if (ID == 1) c_step(ID, 2);
    #10 c_step(ID, 0);
    #10 if (ID == 1) c_step(ID, 1);
  end
endmodule

module test_dpi_context_scope_switch;
  unit #(.ID(1), .START(0)) u1();
  unit #(.ID(2), .START(1)) u2();
endmodule
