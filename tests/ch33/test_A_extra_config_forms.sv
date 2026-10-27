/*
:name: test_A_extra_config_forms
:description: A configuration declaration uses a library-qualified cell selector, an empty liblist, a cell clause with use and the design statement, and each form is accepted while the design keeps its default binding (IEEE 1800-2023 Sections 33.4.1.3, 33.4.1.4, 33.4.1.5 and 33.4.1.6, A.1.5)
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.4.1 33.4.3 A.1.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_A_extra_config_forms.expected
*/
// IEEE 1800-2023 A.1.5, Configuration source text: cell_clause is cell and an
// optionally library-qualified cell_identifier; liblist_clause is liblist and
// zero or more library_identifier, so an empty liblist is legal; use_clause
// names a cell, and the config_rule_statement puts a default, instance or
// cell clause before a liblist or use clause. The design_statement names the
// top cell.
//
// The configuration cfg keeps cf_a in its own library with the empty liblist
// and binds cf_b through use to itself, so the two instances print 1 and 2
// whether or not a tool applies the configuration. A.1.5 also admits named
// parameter assignments after use, but Icarus Verilog 13.0 and the 5.052
// release of Verilator both reject that form, so this test leaves it out.

module cf_a (output logic [3:0] y);
  assign y = 1;
endmodule

module cf_b (output logic [3:0] y);
  assign y = 2;
endmodule

module test_A_extra_config_forms;
  logic [3:0] u1, u2;

  cf_a a1 (u1);
  cf_b b1 (u2);

  initial #1 $display("%0d %0d", u1, u2);
endmodule

config cf;
  design work.test_A_extra_config_forms;
  default liblist work;
  cell cf_a liblist ;
  cell work.cf_b use work.cf_b;
endconfig
