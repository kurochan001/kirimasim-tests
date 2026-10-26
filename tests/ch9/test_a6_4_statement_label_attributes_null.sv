/*
:name: test_a6_4_statement_label_attributes_null
:description: A statement may carry a block identifier prefix and attribute instances, a null statement is attributes and a semicolon, and disabling the named statement stops the statements after it (IEEE 1800-2023 Sections 9.3 and 9.6.2, A.6.4)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.3 9.6.2 A.6.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_a6_4_statement_label_attributes_null.expected
*/
// IEEE 1800-2023 A.6.4: a statement is an optional block identifier and a
// colon, zero or more attribute instances and a statement item; a null
// statement is zero or more attribute instances and a semicolon.
//
// The named statement calls record with "a", which carries the label lbl, and
// then with "b", which carries an attribute instance. An attributed null
// statement and a plain null statement follow. The trace then holds "ab", and
// §9.6.2 makes the disable of the named statement skip the last call, so only
// "ab" is printed. A tool that ignored the label would print "abc".

`timescale 1ns/1ns
module test_a6_4_statement_label_attributes_null;
  string trace = "";

  task automatic record(input string s);
    trace = {trace, s};
  endtask

  initial begin : named
    lbl: record("a");
    (* keep = "true" *) record("b");
    (* keep *) ;
    ;
    if (trace == "ab") disable named;
    record("c");
  end

  initial begin
    #1 $display("trace %s", trace);
    $display("done");
  end
endmodule
