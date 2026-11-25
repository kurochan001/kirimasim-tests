module provider_module(output wire [7:0] value);
  assign value = 8'd19;
  provider_checker check_unit(1'b1);
endmodule

interface provider_interface;
  wire [7:0] value = 8'd23;
endinterface

program provider_program(output logic [7:0] value);
  initial begin
    value = 8'd29;
    #2;
  end
endprogram

checker provider_checker(input logic marker);
  initial begin
    assert (marker) else $fatal(1, "mapped checker received the wrong value");
    $display("checker marker=%b", marker);
  end
endchecker

primitive provider_udp (output y, input x);
  table
    0 : 1;
    1 : 0;
    x : x;
  endtable
endprimitive

package provider_pkg;
  parameter int value = 31;
endpackage

config provider_cfg;
  design work.test_library_contains_all_seven_cell_categories;
  default liblist mappedProvider;
endconfig
