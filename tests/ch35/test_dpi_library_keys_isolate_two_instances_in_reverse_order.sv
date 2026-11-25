/*
:name: test_dpi_library_keys_isolate_two_instances_in_reverse_order
:description: A reverse-order library update shares numeric keys only inside its own instance
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.3 H.9.3 J.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: dpi_user_keys/library_b.cpp
:dpi_c: @dpi_user_keys/library_a.c
:expected_stdout: @test_dpi_library_keys_isolate_two_instances_in_reverse_order.expected
*/
module key_access_cell;
  import "DPI-C" context function int user_keys_a_put(input int slot);
  import "DPI-C" context function int user_keys_b_put(input int slot);
  import "DPI-C" context function int user_keys_a_private();
  import "DPI-C" context function int user_keys_b_private();
  import "DPI-C" context function int user_keys_a_numeric();
  import "DPI-C" context function int user_keys_b_numeric();

  task automatic display_keys();
    $display("keys snapshot private=%0d,%0d numeric=%0d,%0d",
             user_keys_a_private(), user_keys_b_private(),
             user_keys_a_numeric(), user_keys_b_numeric());
  endtask

  task automatic store_b(input int slot);
    $display("keys B put=%0d", user_keys_b_put(slot));
  endtask

  task automatic store_a(input int slot);
    $display("keys A put=%0d", user_keys_a_put(slot));
  endtask
endmodule

module test_dpi_library_keys_isolate_two_instances_in_reverse_order;
  key_access_cell first();
  key_access_cell second();

  initial begin
    first.store_b(0);
    first.display_keys();
    second.display_keys();
    first.store_a(0);
    first.display_keys();
    second.store_a(1);
    second.store_b(1);
    second.display_keys();
    first.display_keys();
  end
endmodule
