/*
:name: test_class_managed_storage_lifetime
:description: Observe storage for a class object, dynamic array, associative array and string
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.29
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_class_managed_storage_lifetime.c
:expected_stdout: @test_class_managed_storage_lifetime.expected
*/
class managed_storage;
  int dynamic_values[];
  int sparse[int];
  string text_value;
endclass

module test_class_managed_storage_lifetime;
  timeunit 1ns;
  timeprecision 1ns;

  import "DPI-C" function longint unsigned managed_heap_bytes();
  import "DPI-C" function int check_managed_string(input string contents);

  managed_storage mem;
  longint unsigned baseline, with_object, with_dynamic, with_assoc, with_string, final_bytes;

  initial begin
    baseline = managed_heap_bytes();
    mem = new;
    with_object = managed_heap_bytes();

    mem.dynamic_values = new[8192];
    mem.dynamic_values[8191] = 41;
    with_dynamic = managed_heap_bytes();

    for (int i = 0; i < 2048; i++)
      mem.sparse[3*i] = i;
    with_assoc = managed_heap_bytes();

    mem.text_value = "abcdefghijklmnop";
    repeat (14)
      mem.text_value = {mem.text_value, mem.text_value};
    with_string = managed_heap_bytes();

    $display("values %0d %0d %0d", mem.dynamic_values[8191], mem.sparse[6141],
             check_managed_string(mem.text_value));
    if ($test$plusargs("drop_handle"))
      mem = null;
    #1;
    final_bytes = managed_heap_bytes();
    if ($test$plusargs("observe_heap")) begin
      $display("heap %0d %0d %0d %0d %0d %0d handle=%0d", baseline, with_object,
               with_dynamic, with_assoc, with_string, final_bytes, mem != null);
    end
    $finish(0);
  end
endmodule
