/*
:name: test_case_inside_evaluation_order_by_qualifier
:description: case inside evaluates its expression and items in the order of a normal, priority or unique case (IEEE 1800-2023 Section 12.5.4)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5.4 12.5 12.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_case_inside_evaluation_order_by_qualifier.expected
*/
// IEEE 1800-2023 §12.5.4: the case expression and the items of a case-inside
// statement are evaluated in the order that a normal case, unique-case or
// priority-case statement prescribes. For a normal case (12.5), which a
// priority-case follows (it acts on the first match, 12.5.3), the case
// expression is evaluated once and first, the items are evaluated in the order
// written, and the search stops at the first match; the default item is
// skipped during the search. For a unique-case (12.5.3) the case expression is
// evaluated once before any item, and the items may be evaluated in any order
// but the evaluation continues after a match, so with exactly one matching
// item every item is evaluated.
// Each function call adds a letter to trace: E for the case expression and the
// given tag for an item. Every item has one expression, so the order inside a
// range_list (11.4.13) plays no part. For the unique-case only the first letter
// and the number of each tag are printed, as the order of the items is open.
// Icarus Verilog 13.0 does not support case inside. Verilator 5.052 evaluates
// the items more than once and goes on after the match: it prints Eabcab for
// the first statement.

module test_case_inside_evaluation_order_by_qualifier;
  string trace;
  int r;

  function automatic int sel(int v);
    trace = {trace, "E"};
    return v;
  endfunction

  function automatic int item(int v, string tag);
    trace = {trace, tag};
    return v;
  endfunction

  function automatic int count(string tag);
    int n = 0;
    foreach (trace[i])
      if (trace[i] == tag[0]) n++;
    return n;
  endfunction

  initial begin
    trace = ""; r = -1;
    case (sel(5)) inside
      item(1, "a"): r = 1;
      item(5, "b"): r = 2;
      item(5, "c"): r = 3;
      default:      r = 0;
    endcase
    $display("normal match: %s r=%0d", trace, r);

    trace = ""; r = -1;
    case (sel(7)) inside
      item(1, "a"): r = 1;
      default:      r = 0;
      item(5, "b"): r = 2;
    endcase
    $display("normal default: %s r=%0d", trace, r);

    trace = ""; r = -1;
    priority case (sel(5)) inside
      item(1, "a"): r = 1;
      item(5, "b"): r = 2;
      item(5, "c"): r = 3;
    endcase
    $display("priority: %s r=%0d", trace, r);

    trace = ""; r = -1;
    unique case (sel(5)) inside
      item(1, "a"): r = 1;
      item(5, "b"): r = 2;
      item(9, "c"): r = 3;
    endcase
    $display("unique: first=%s E=%0d a=%0d b=%0d c=%0d r=%0d", trace.substr(0, 0),
             count("E"), count("a"), count("b"), count("c"), r);
  end
endmodule
