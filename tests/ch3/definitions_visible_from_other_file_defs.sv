// A source of test_definitions_visible_from_other_file, compiled before it
// (:files:): one package, one interface, one primitive, one module and one
// program, each used by name from the test's own file.

package dvo_pkg;
  parameter int DVO_K = 5;

  function automatic int dvo_twice(int x);
    return 2 * x;
  endfunction
endpackage

interface dvo_bus;
  logic [7:0] v;
endinterface

primitive dvo_inv (output y, input a);
  table
    0 : 1;
    1 : 0;
  endtable
endprimitive

module dvo_add (input logic [7:0] i, output logic [7:0] o);
  assign o = i + dvo_pkg::DVO_K;
endmodule

program dvo_report (input logic [7:0] v);
  initial #3 $display("program: v=%0d", v);
endprogram
