/*
:name: test_vpi_bulk_array_checks_element_type_and_storage_lifetime
:description: VPI bulk transfer distinguishes eligible static arrays from dynamic storage and unpacked element types
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.16 38.35
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_bulk_array_checks_element_type_and_storage_lifetime.expected
:vpi_c: @test_vpi_bulk_array_checks_element_type_and_storage_lifetime.c
*/
module test_vpi_bulk_array_checks_element_type_and_storage_lifetime;
  typedef struct packed { bit [3:0] high, low; } packed_item;
  typedef struct { bit [3:0] high, low; } unpacked_item;
  packed_item packed_items[0:1];
  unpacked_item records[0:1];
  string strings[0:1];
  int variable_length[];
  wire [7:0] net_items[0:1];

  assign net_items[0] = 8'd17;
  assign net_items[1] = 8'd23;

  task automatic inspect_automatic_array();
    int local_items[0:1] = '{41, 42};
    $display("automatic local before put=%0d", local_items[0]);
    $vt_check_bulk_array(5);
  endtask

  task static inspect_static_array();
    static int local_items[0:1] = '{47, 48};
    $vt_check_bulk_array(6);
    $display("static local after put=%0d", local_items[0]);
  endtask

  initial begin
    packed_items[0] = 8'h15;
    packed_items[1] = 8'h26;
    records[0] = '{2, 3};
    strings[0] = "a";
    strings[1] = "b";
    variable_length = new[2];
    variable_length[0] = 37;
    #1;
    $vt_check_bulk_array(0, packed_items);
    $display("packed after put=%0d", packed_items[0]);
    $vt_check_bulk_array(1, net_items);
    $display("net after put=%0d", net_items[0]);
    $vt_check_bulk_array(2, records);
    $vt_check_bulk_array(3, strings);
    $vt_check_bulk_array(4, variable_length);
    inspect_automatic_array();
    inspect_static_array();
  end
endmodule
