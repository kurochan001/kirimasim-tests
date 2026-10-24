/*
:name: test_vpi_case_items_patterns
:description: A case iterates its case items; an item groups all the expressions that branch to its statement, gives them with vpiExpr and its statement with vpiStmt, and the default item has no expression iterator; in a case matches the items give their patterns, a tagged pattern its member name and nested pattern, an any pattern its identifier, and a constant pattern is an expression (IEEE 1800-2023 Section 37.72)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.72 12.5 12.6 12.6.1 37.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_case_items_patterns.c
:expected_stdout: @test_vpi_case_items_patterns.expected
*/
// IEEE 1800-2023 §37.72: a case iterates its case items; vpi_iterate(vpiExpr)
// on an item gives its patterns or expressions, and vpiStmt its statement. An
// item groups all the case conditions that branch to the same statement
// (detail 1), and the iterator of the default item is NULL, as it has no
// expression (detail 2). A pattern is an any pattern, a tagged pattern, a
// struct pattern or an expression. A tagged pattern has as vpiName its member
// name and leads to its nested pattern (vpiPattern); an any pattern has a name.
// §12.6: the pattern .identifier matches any value and declares the
// identifier, so it is the any pattern, named by that identifier; a constant
// expression is a pattern, and tagged Empty has no nested pattern.
//
// The task stmts is never called, so its statements only exist as VPI
// objects; it has several statements, so its vpiStmt is an unnamed begin
// (37.12 detail 5). Every item has a different statement, so the application
// prints one line per item: the condition of its case, its statement and its
// expressions (sorted, as is the list of lines). A constant is printed as its
// value, an any pattern as . and its name, a tagged pattern as tagged, its
// name and its nested pattern; a NULL iterator as NULL.
// Neither release produces this output: Icarus Verilog 13.0 cannot build the
// application, as its headers lack vpiStmt and the pattern types, and the
// void member of the tagged union stops Verilator 5.052, which does not
// support it.

module test_vpi_case_items_patterns;
  typedef union tagged {
    int Num;
    void Empty;
  } item_t;

  int s, v;
  item_t u;

  task stmts;
    case (s)
      1, 2: v = 10;
      3: v = 20;
      default: v = 30;
    endcase
    case (u) matches
      tagged Num 5: v = 41;
      tagged Num .n: v = n;
      tagged Empty: v = 42;
    endcase
    case (s) matches
      7: v = 60;
      .k: v = k;
    endcase
  endtask
endmodule
