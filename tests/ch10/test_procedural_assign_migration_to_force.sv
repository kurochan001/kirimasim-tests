/*
:name: test_procedural_assign_migration_to_force
:description: A variable driven by assign and deassign can use force and release
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.6.1 10.6.2 C.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_procedural_assign_migration_to_force
:expected_stdout: @test_procedural_assign_migration_to_force.expected
*/
`timescale 1ns/1ns
module test_procedural_assign_migration_to_force;
  logic [7:0] source = 2;
  logic [7:0] legacy, migrated;
  initial begin
    legacy = 1;
    migrated = 1;
    #1 $display("before=%0d,%0d", legacy, migrated);
    assign legacy = source;
    force migrated = source;
    #1 source = 9;
    #1 $display("following=%0d,%0d", legacy, migrated);
    legacy = 99;
    migrated = 99;
    #1 $display("overridden=%0d,%0d", legacy, migrated);
    deassign legacy;
    release migrated;
    #1 source = 27;
    #1 $display("held=%0d,%0d", legacy, migrated);
    legacy = 42;
    migrated = 42;
    #1 $display("written=%0d,%0d", legacy, migrated);
    $finish(0);
  end
endmodule
