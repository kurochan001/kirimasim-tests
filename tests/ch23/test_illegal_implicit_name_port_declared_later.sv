/*
:name: test_illegal_implicit_name_port_declared_later
:description: The name of a .name connection has to be declared or imported before the connection; a declaration later in the module is too late (IEEE 1800-2023 Section 23.3.2.3)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.2.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the .data connection of u comes before the declaration of data in the instantiating module
:expected_stderr_regex: test_illegal_implicit_name_port_declared_later\.sv:44:
*/
// IEEE 1800-2023 §23.3.2.3: it is an error when the name of a .name port
// connection has not been declared, explicitly or implicitly, or imported
// from a package, explicitly or by a wildcard import, before the connection.
// The instance ok connects three names that all exist by then: q is declared
// explicitly, w is an implicit net declared by its use in the port list of
// the instance src (6.10), and cfg is imported by the wildcard import of
// dl_pkg. The instance u connects data, which the module declares only after
// it.
// Oracle checks: Icarus Verilog 13.0 reports the missing data of u, but it also
// rejects the legal .cfg of ok, a name imported by the wildcard import; the
// 5.052 release of Verilator accepts the design.

package dl_pkg;
  logic [3:0] cfg = 4'd3;
endpackage

module dl_source(output wire w);
  assign w = 1'b1;
endmodule

module dl_child(input logic [3:0] data, input logic [3:0] cfg, input wire w,
                output logic [3:0] q);
  assign q = w ? data + cfg : 4'd0;
endmodule

module test_illegal_implicit_name_port_declared_later;
  import dl_pkg::*;
  logic [3:0] q, q2;
  dl_source src (.w(w));
  dl_child ok (.data(4'd1), .cfg, .w, .q);
  dl_child u (.data, .cfg, .w, .q(q2));   // illegal: data is declared below
  logic [3:0] data = 4'd5;
endmodule
