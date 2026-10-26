/*
:name: test_config_declaration_grammar_forms
:description: A configuration declaration has a name, zero or more localparam declarations, a design statement, config rules with default, instance and cell selection and liblist and use expansion, and endconfig with an optional name; the rules bind a cell through a library, keep it in its own library with an empty liblist, and override a parameter (IEEE 1800-2023 Sections 33.4.1.1, 33.4.1.3, 33.4.1.4, 33.4.1.5, 33.4.1.6 and 33.4.3)
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.4.1 33.4.3 A.1.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_config_declaration_grammar_forms.expected
*/
// IEEE 1800-2023 A.1.5, Configuration source text: config_declaration is the
// keyword config, a config_identifier, a semicolon, zero or more
// local_parameter_declarations, one design_statement, zero or more
// config_rule_statements, the keyword endconfig and an optional colon and
// config_identifier. design_statement is design followed by one or more
// [library_identifier .] cell_identifier names. A config rule is a
// default_clause, an inst_clause or a cell_clause followed by a liblist_clause
// or a use_clause; a liblist_clause is liblist followed by zero or more
// library_identifiers, and a use_clause names a cell, optionally with named
// parameter assignments, and optionally the suffix : config. A.1.5 writes the
// parameter assignments directly after the cell name, without the # that the
// examples of 33.4.3 use; this test takes the A.1.5 form.
//
// The configuration cfg has the localparam WIDTH = 7 and the design
// work.test_config_declaration_grammar_forms. Its instance rule binds a1 to
// cf_b, its cell rule with the empty liblist leaves a2 as cf_a, and its cell
// rule for the library-qualified cf_p binds p3 with W = WIDTH, so the
// instances print 0b, 0a and 7. The endconfig names the configuration again.
// A tool that ignores the configuration leaves a1 as cf_a and p3 with its
// default W = 1.

module cf_a (output logic [7:0] y);
  assign y = 8'h0a;
endmodule

module cf_b (output logic [7:0] y);
  assign y = 8'h0b;
endmodule

module cf_p #(parameter int W = 1) (output logic [7:0] y);
  assign y = W;
endmodule

module test_config_declaration_grammar_forms;
  logic [7:0] u1, u2, u3;

  cf_a a1 (u1);
  cf_a a2 (u2);
  cf_p p3 (u3);

  initial #1 $display("u1=%h u2=%h u3=%0d", u1, u2, u3);
endmodule

config cf_cfg;
  localparam int WIDTH = 7;
  design work.test_config_declaration_grammar_forms;
  default liblist work;
  instance test_config_declaration_grammar_forms.a1 use work.cf_b;
  cell cf_a liblist ;
  cell work.cf_p use work.cf_p .W(WIDTH);
endconfig : cf_cfg
