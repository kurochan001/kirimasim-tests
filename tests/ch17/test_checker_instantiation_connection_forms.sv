/*
:name: test_checker_instantiation_connection_forms
:description: A checker is instantiated with its package-qualified name and one instance name, and its ports connect by position, by position with an attribute on an entry, by name with every actual written, by an implicit name and by the .* wildcard (IEEE 1800-2023 Section 17.3)
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
// entries are either ordered or named. A named entry here is .formal or
// .formal(actual). The wildcard .* connects every formal whose name matches a
// variable of the instantiating scope. An output connection passes a value to
// a variable of the outer scope (§17.3).
//
// ck_add takes a, b and c and writes their sum and the parity of a. The
// instances connect by position, by position with an attribute on the first
// entry, by name with every actual written, by implicit names, and by .*. a is
// 1, b is 2 and c is 4, so every sum is 7 and every parity is 1. Each instance
// writes to its own variables, since an output connection acts as a continuous
// assignment to its actual (§17.3), of which a variable may have only one
// (§6.5).
//
// The grammar of A.4.1.4 also has an empty actual: an ordered entry with no
// actual, and .formal(). §17.3 compares these connections with module ports
// (§23.3.2), where an empty connection leaves the port unconnected, but it also
// says that each actual output argument is a variable or net lvalue, and §16.8
// asks for an actual for each formal that has no default. slang rejects an
// empty actual, so the suite accepts either reading and this test has none.
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
  logic [5:0] s_pos, s_attr, s_named, s_imp, sum;
  logic f_pos, f_attr, f_named, f_imp, flag;

  ck_inst_pkg::ck_add u_pos (a, b, c, s_pos, f_pos);

  ck_inst_pkg::ck_add u_attr ((* keep = "yes" *) a, b, c, s_attr, f_attr);

  ck_inst_pkg::ck_add u_named (.a(a), .b(b), .c(c), .sum(s_named), .flag(f_named));

  ck_inst_pkg::ck_add u_imp (.a, .b, .c, .sum(s_imp), .flag(f_imp));

  ck_inst_pkg::ck_add u_wild (.*);

  initial begin
    #1;
    $write("position: %0d/%b, attribute: %0d/%b, named: %0d/%b, ",
           s_pos, f_pos, s_attr, f_attr, s_named, f_named);
    $display("implicit: %0d/%b, wildcard: %0d/%b", s_imp, f_imp, sum, flag);
  end
endmodule
