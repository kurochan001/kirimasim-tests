/*
:name: test_statement_null_labels_attributes
:description: A statement_or_null can be a semicolon with attributes, and a statement can carry a block identifier and attributes, so null statements in a block, in an if and in a case item leave the values unchanged (IEEE 1800-2023 Section 12.3)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.3 12.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_statement_null_labels_attributes.expected
*/
// IEEE 1800-2023 §12.3: statement_or_null is a statement or an optionally
// attributed semicolon, and statement is an optional block identifier,
// attribute instances and a statement_item. The initial block below uses both
// forms: a bare and an attributed null statement in a sequential block, a
// labeled and an attributed assignment, a null statement as the taken branch
// of an if, and a null statement as a case default. None of them changes x,
// and bump runs once from the case item, so x is 3 and hits is 1.

module test_statement_null_labels_attributes;
  int x = 0;
  int hits = 0;

  task automatic bump();
    x++;
    hits++;
  endtask

  initial begin : outer
    begin : inner
      ;
      (* keep = "true" *) ;
    end
    lbl_a: x = 1;
    (* keep = "true" *) x = x + 1;
    if (x == 2) ; else x = 99;
    case (x)
      2: bump();
      default: ;
    endcase
    $display("x=%0d hits=%0d", x, hits);
  end
endmodule
