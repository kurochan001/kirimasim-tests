/*
:name: test_syntax_loop_statement_forms
:description: forever, repeat, while, do while and for with each initialization and step form, and foreach with package-scoped, hierarchical, partial and omitted loop variables, repeat the statements of A.6.8 and 12.7 as many times as their controls say (IEEE 1800-2023 Section 12.7, A.6.8)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7 12.7.1 12.7.2 12.7.3 12.7.4 12.7.5 12.7.6 A.6.8 A.6.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_loop_statement_forms.expected
*/
// IEEE 1800-2023 A.6.8: a loop statement is forever, repeat (expression),
// while (expression), for ([initialization]; [expression]; [step]), do
// statement while (expression); or foreach (array [loop_variables]). The
// initialization is a list of variable assignments or one or more for
// variable declarations with optional var and data type, and the step is a
// list of operator assignments, increment or decrement expressions or
// function calls. loop_variables are optional index identifiers separated by
// commas, so a dimension can be left out.
//
// The test counts the passes of each loop. The for loops use all the
// initialization forms: two variable assignments, one declaration with two
// identifiers, two declarations, and a var declaration; the steps are
// "i++", "j--", a function call that increments its ref argument, and an
// assignment. The foreach loops sum a one-dimensional array, count a
// two-dimensional array with both indices, sum columns with the row index
// left out, and count with both indices left out. §12.7.3: an omitted loop
// variable means no iteration over that dimension, so the column counter runs
// once for each column, the row counter once for each row, and the counter
// with no loop variable not at all. One array is in a package and one in an
// instance, which the foreach names with a package scope and a hierarchical
// identifier.

package loop_pkg;
  int nums[3] = '{1, 2, 3};
endpackage

module loop_holder;
  int values[3] = '{10, 20, 30};
endmodule

module test_syntax_loop_statement_forms;
  import loop_pkg::*;

  function automatic void bump(ref int x);
    x = x + 1;
  endfunction

  loop_holder u();

  int forever_count, repeat_count, while_count, do_count;
  int for_a, for_b, for_c, for_d, for_empty;
  int sum, count, both, pkg_sum, hier_sum;
  int col[3] = '{0, 0, 0};
  int row[2] = '{0, 0};
  int m2[2][3] = '{'{1, 2, 3}, '{4, 5, 6}};

  initial begin
    forever begin
      forever_count++;
      if (forever_count == 3) break;
    end

    repeat (3) repeat_count++;
    repeat (0) repeat_count = repeat_count + 100;

    while (while_count < 4) while_count++;

    do do_count++; while (do_count < 2);

    begin
      int i, j;
      for (i = 0, j = 10; i < 3; i++, j--) for_a = for_a + i + j;
    end

    for (int k = 0, m = 2; k < 2; k++) for_b = for_b + m;

    for (int p = 0, int q = 1; p < 2; p++, q++) for_c = for_c + q;

    for (var int s = 0; s < 4; bump(s)) for_d++;

    for (;;) begin
      for_empty++;
      if (for_empty == 2) break;
    end

    foreach (m2[i, j]) begin
      sum = sum + m2[i][j];
      count++;
    end
    foreach (m2[, j]) col[j]++;
    foreach (m2[i, ]) row[i]++;
    foreach (m2[, ]) both++;
    foreach (loop_pkg::nums[i]) pkg_sum = pkg_sum + loop_pkg::nums[i];
    foreach (u.values[i]) hier_sum = hier_sum + u.values[i];

    $display("counts: forever=%0d repeat=%0d while=%0d do=%0d",
             forever_count, repeat_count, while_count, do_count);
    $display("for: a=%0d b=%0d c=%0d d=%0d empty=%0d",
             for_a, for_b, for_c, for_d, for_empty);
    $display("foreach: sum=%0d count=%0d both=%0d", sum, count, both);
    $display("columns: %0d %0d %0d", col[0], col[1], col[2]);
    $display("rows: %0d %0d", row[0], row[1]);
    $display("scoped: pkg=%0d hier=%0d", pkg_sum, hier_sum);
  end
endmodule
