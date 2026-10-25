/*
:name: test_for_comma_items_and_earlier_local
:description: A for loop accepts several comma-separated initializations and several comma-separated steps of each kind (assignment, increment, decrement, function call), and a local variable declared in the initialization can be initialized from an earlier one (IEEE 1800-2023 Section 12.7.1)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_for_comma_items_and_earlier_local.expected
*/
// IEEE 1800-2023 §12.7.1: the initialization of a for loop can be several
// comma-separated assignments or declarations, and the step several
// comma-separated assignments, increment or decrement expressions or
// function calls. When the initialization declares several local variables,
// the initializer of one can use the variables declared before it.
//
// The first loop assigns x and y and has the steps x += 3, y--, z = z * 2
// and the void function call count_step(); no step reads a variable that
// another step writes, so the order of the steps does not matter. The body
// shows x/y and z each time. The second loop declares a, b = a * 10 and
// c = b + a, so b and c come from the local a (2), not from the module
// variable a (100), and steps with a++ and c--.

module test_for_comma_items_and_earlier_local;
  int a = 100;
  int x, y, z, n;
  string trace;

  function automatic void count_step();
    n++;
  endfunction

  initial begin
    trace = "";
    z = 1;
    n = 0;
    for (x = 0, y = 10; x < y; x += 3, y--, z = z * 2, count_step())
      trace = {trace, $sformatf(" %0d/%0d,z=%0d", x, y, z)};
    $display("assigned x, y:%s; after: x=%0d y=%0d z=%0d calls=%0d", trace, x, y, z, n);

    trace = "";
    for (int a = 2, b = a * 10, c = b + a; a < 5; a++, c--)
      trace = {trace, $sformatf(" %0d/%0d/%0d", a, b, c)};
    $display("declared a, b, c:%s; module a=%0d", trace, a);
  end
endmodule
