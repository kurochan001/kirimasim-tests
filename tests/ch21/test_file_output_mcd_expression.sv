/*
:name: test_file_output_mcd_expression
:description: The first argument of $fdisplay can be a multichannel descriptor held in a variable or computed by an expression, such as a bitwise OR of descriptors, a conditional operator or a function call, and the output goes to every channel the 32-bit value selects (IEEE 1800-2023 Section 21.3.2)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.2 21.3.1 21.3.4.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_file_output_mcd_expression.expected
*/
// IEEE 1800-2023 §21.3.2: the multichannel descriptor that directs the output
// of a file output task is either a variable or the result of an expression
// that has the form of a 32-bit unsigned integer. Two files are opened
// without a type, which returns multichannel descriptors (21.3.1). A line goes
// to file a through a variable, one to both files through a | b, one to file b
// through a conditional operator and one to file a through a function call;
// a | 1 also selects channel 0, the standard output, so that line is printed
// at once. Then the files are read back with $fgets (21.3.4.2). The files are
// created in the current directory.

module test_file_output_mcd_expression;
  integer a, b;
  bit sel;

  function automatic integer pick(bit second);
    return second ? b : a;
  endfunction

  task automatic show(string name);
    int fr = $fopen(name, "r");
    string line;
    while ($fgets(line, fr) != 0) $display("%s: %s", name, line.substr(0, line.len() - 2));
    $fclose(fr);
  endtask

  initial begin
    a = $fopen("test_mcd_expr_a.txt");
    b = $fopen("test_mcd_expr_b.txt");
    sel = 1;
    $fdisplay(a, "variable");
    $fdisplay(a | b, "or of two");
    $fdisplay(sel ? b : a, "conditional");
    $fdisplay(pick(0), "function");
    $fdisplay(a | 1, "with stdout");
    $fclose(a | b);
    show("test_mcd_expr_a.txt");
    show("test_mcd_expr_b.txt");
  end
endmodule
