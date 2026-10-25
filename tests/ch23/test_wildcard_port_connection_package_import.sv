/*
:name: test_wildcard_port_connection_package_import
:description: A .* connection is not a reference that imports a name through a wildcard package import, so a defaulted input whose name only the package declares gets its default, while a .name or explicit named connection in the same instance imports the package name and connects it (IEEE 1800-2023 Section 23.3.2.4)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.2.4 26.3 23.2.2.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_wildcard_port_connection_package_import.expected
*/
// IEEE 1800-2023 §26.3: a wildcard import makes the names of a package
// candidates, and a name is imported only when the importing scope
// references it. §23.3.2.4: .* does not count as such a reference, so for
// .* the name does not exist in the instantiating scope, and an input with
// a default value (§23.2.2.4) gets its default; a .name connection, or a
// named connection whose expression uses the name, mixed with .* is a
// reference that imports it.
// The package declares the variable p = 4'h8. Each of three modules imports
// the package with a wildcard import, declares y, and instantiates a leaf
// whose input p defaults to 4'h5 and whose output y shows p:
//   star_only (.*): p is not imported, so p takes its default 5;
//   named_ref (.p, .*): the .p connection imports p, so p = 8;
//   explicit_ref (.p(p), .*): the expression p imports it as well, 8.
// Each module has a scope of its own, so the import that one triggers does
// not affect the others. Icarus Verilog 13.0 does not import p for the .p
// connection and stops with an error; Verilator 5.052 imports p for none of
// the connections and prints 5 three times.

package wildcard_port_connection_package_import_pkg;
  logic [3:0] p = 4'h8;
endpackage

module wildcard_port_connection_package_import_leaf(input logic [3:0] p = 4'h5,
                                                    output logic [3:0] y);
  assign y = p;
endmodule

module wildcard_port_connection_package_import_star_only;
  import wildcard_port_connection_package_import_pkg::*;
  logic [3:0] y;
  wildcard_port_connection_package_import_leaf u(.*);
endmodule

module wildcard_port_connection_package_import_named_ref;
  import wildcard_port_connection_package_import_pkg::*;
  logic [3:0] y;
  wildcard_port_connection_package_import_leaf u(.p, .*);
endmodule

module wildcard_port_connection_package_import_explicit_ref;
  import wildcard_port_connection_package_import_pkg::*;
  logic [3:0] y;
  wildcard_port_connection_package_import_leaf u(.p(p), .*);
endmodule

module test_wildcard_port_connection_package_import;
  wildcard_port_connection_package_import_star_only s();
  wildcard_port_connection_package_import_named_ref n();
  wildcard_port_connection_package_import_explicit_ref x();

  initial begin
    #1;
    $display("star_only (.*): p=%h", s.y);
    $display("named_ref (.p, .*): p=%h", n.y);
    $display("explicit_ref (.p(p), .*): p=%h", x.y);
  end
endmodule
