/*
:name: test_vpi_loop_var_scopes
:description: A for statement that declares its loop variable has vpiLocalVarDecls TRUE and is a scope, the scope of that variable and of the calls in its body, while a for statement over an outside variable is not a scope; a foreach statement is the scope of its loop variable (IEEE 1800-2023 Section 37.12)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.12 37.74 37.75 12.7.1 12.7.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_loop_var_scopes.c
:expected_stdout: @test_vpi_loop_var_scopes.expected
*/
// IEEE 1800-2023 §37.12: for and foreach stmt are in the scope group. A for
// statement is a scope if, and only if, its vpiLocalVarDecls property is TRUE,
// that is, it declares its loop variables (37.74, 12.7.1); then the scope of
// each loop variable is the for statement (detail 2). The scope of the loop
// variable of a foreach statement is the foreach statement (detail 3, 12.7.3).
// Block b has three loops, each running its body once: a for over the module
// variable j, a for that declares i, and a foreach over arr whose body calls
// for k == 1 only. Each call passes the loop variable; the application prints
// the scope of the call, whether the scope of the variable is that same scope,
// and for a for statement its vpiLocalVarDecls. The first for is not a scope,
// so the call in it is in b and j is in the module. At the end, $vt_fors walks
// the statements of b by line and prints vpiLocalVarDecls of each for.

module test_vpi_loop_var_scopes;
  int j;
  int arr [2];

  initial begin : b
    for (j = 0; j < 1; j++) $vt_loop("A", j);
    for (int i = 0; i < 1; i++) $vt_loop("B", i);
    foreach (arr[k]) if (k == 1) $vt_loop("C", k);
    $vt_fors;
  end
endmodule
