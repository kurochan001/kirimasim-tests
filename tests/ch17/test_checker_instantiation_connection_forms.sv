/*
:name: test_checker_instantiation_connection_forms
:description: A checker is instantiated with its package-qualified name and one instance name, and its ports connect by position with an omitted actual, by name with an explicit or an empty actual, by an implicit name and by the .* wildcard (IEEE 1800-2023 Section 17.3)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.3 17.2 A.4.1.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_instantiation_connection_forms.expected
*/
// IEEE 1800-2023 §17.3 with A.4.1.4: a checker instance is the
// package-qualified checker name, one instance name and a port list whose
// entries are either ordered or named. An ordered entry may be empty, which
// leaves that formal unconnected; a named entry is .formal, .formal(actual)
// or .formal(). The wildcard .* connects every formal whose name matches a
// variable of the instantiating scope. An output connection passes a value
// to a variable of the outer scope (§17.3).
//
// ck_add takes a, b and c and writes their sum and the parity of a. The
// instances connect by position, by position with the attribute and the
// unused output left empty, by name with every actual written and .flag()
// empty, by implicit names, and by .*. a is 1, b is 2 and c is 4, so every
// sum is 7; the two instances that leave the parity output empty write
// nothing to it.
// Icarus Verilog 13.0 does not parse checkers, and Verilator 5.052 does not
// support a checker declared in a package, so the expected output follows the
// standard; with the same checker at unit level Verilator 5.052 reproduces it.

package ck_inst_pkg;
  checker ck_add (input logic [3:0] a, input logic [3:0] b,
                  input logic [3:0] c, output logic [5:0] sum,
                  output logic flag);
    assign sum = a + b + c;
    assign flag = ^a;
  endchecker : ck_add
endpackage : ck_inst_pkg

module test_checker_instantiation_connection_forms;
  logic [3:0] a = 4'd1, b = 4'd2, c = 4'd4;
  logic [5:0] s_pos, s_skip, s_named, s_imp, sum;
  logic f_pos, flag;

  ck_inst_pkg::ck_add u_pos (a, b, c, s_pos, f_pos);

  ck_inst_pkg::ck_add u_skip ((* keep = "yes" *) a, b, c, s_skip, );

  ck_inst_pkg::ck_add u_named (.a(a), .b(b), .c(c), .sum(s_named), .flag());

  ck_inst_pkg::ck_add u_imp (.a, .b, .c, .sum(s_imp), .flag(flag));

  ck_inst_pkg::ck_add u_wild (.*);

  initial begin
    #1 $display("position: %0d/%b, omitted: %0d, empty: %0d, implicit: %0d, wildcard: %0d",
                s_pos, f_pos, s_skip, s_named, s_imp, sum);
  end
endmodule
