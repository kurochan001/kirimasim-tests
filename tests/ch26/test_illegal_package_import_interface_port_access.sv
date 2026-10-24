/*
:name: test_illegal_package_import_interface_port_access
:description: a name that an interface imports from a package cannot be reached through an interface port of that interface (IEEE 1800-2023 Section 26.3)
:tags: ch26
:type: elaboration
:lrm: 1800-2023 26.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: module ip_reader reads port.shared, but shared is only imported into interface ip_bus, not declared there
:expected_stderr_regex: test_illegal_package_import_interface_port_access\.sv:33:
*/
// IEEE 1800-2023 §26.3: an import makes a package declaration visible in the
// importing scope without copying it, so it cannot be referenced through an
// interface port of the importing interface. Interface ip_bus imports
// ip_pkg::shared and declares sig; module ip_reader reads port.sig, which
// is legal, and port.shared. Icarus Verilog 13.0 does not parse the
// interface port of ip_reader, an error at another line, which does not
// count.

package ip_pkg;
  int shared = 4;
endpackage

interface ip_bus;
  import ip_pkg::shared;
  int sig = 6;
endinterface

module ip_reader (ip_bus port);
  initial #1 $display("%0d", port.sig);
  initial #2 $display("%0d", port.shared);   // illegal
endmodule

module test_illegal_package_import_interface_port_access;
  ip_bus bus ();
  ip_reader r (.port(bus));
endmodule
