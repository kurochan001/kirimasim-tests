/*
:name: test_class_collection_leaves_foreign_allocation
:description: Drop both class handles and leave the foreign allocation under C ownership
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.4 8.29
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_class_collection_leaves_foreign_allocation.c
:expected_stdout: @test_class_collection_leaves_foreign_allocation.expected
*/
class collection_sample;
  int value;
  chandle foreign;
endclass

module test_class_collection_leaves_foreign_allocation;
  timeunit 1ns;
  timeprecision 1ns;

  import "DPI-C" function chandle new_foreign_payload();
  import "DPI-C" function int read_foreign_payload(chandle handle_value);
  import "DPI-C" function int read_native_payload();
  import "DPI-C" function void free_foreign_payload();

  collection_sample original, remaining;

  initial begin
    original = new;
    original.value = 17;
    original.foreign = new_foreign_payload();
    remaining = original;
    #1 original = null;
    #1;
    $display("alias live t=%0d value=%0d foreign=%0d",
             $time, remaining.value, read_foreign_payload(remaining.foreign));
    #1;
    $display("dropping last handle t=%0d", $time);
    $fflush();
    remaining = null;
    #1;
    $display("native storage t=%0d handles cleared=%0d value=%0d",
             $time, original == null && remaining == null, read_native_payload());
    free_foreign_payload();
    $finish(0);
  end
endmodule
