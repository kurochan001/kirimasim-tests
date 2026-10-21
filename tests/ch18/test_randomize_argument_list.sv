/*
:name: test_randomize_argument_list
:description: randomize() with arguments makes the listed properties the only random variables of the call, also one not declared rand, and the other rand properties keep their values as state variables (IEEE 1800-2023 Section 18.11)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.11 18.6.1 18.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randomize_argument_list.expected
*/
// IEEE 1800-2023 §18.11: called with arguments, randomize() gives new values
// only to the properties it names, which can include properties not declared
// rand; every other property, rand or not, is a state variable for that call.
// The constraint ties a to b and c to a, so each call has one solution: with
// randomize(b) the rand a keeps 40 and b becomes 39, a value the solver alone
// can pick; with randomize(c) only c changes; with no arguments a and c are
// random again and b, not rand, is a state variable.

class test_randomize_argument_list_c;
  rand int a;
  int b;
  rand int c;
  constraint tie { a == b + 1; c == a * 2; b inside {[0:100]}; }
endclass

module test_randomize_argument_list;
  test_randomize_argument_list_c o = new;
  int ok;

  initial begin
    o.a = 40;
    o.b = 0;
    o.c = 0;
    ok = o.randomize(b, c);
    $display("randomize(b, c): ok=%0d a=%0d b=%0d c=%0d", ok, o.a, o.b, o.c);
    o.a = 10;
    o.b = 9;
    ok = o.randomize(c);
    $display("randomize(c): ok=%0d a=%0d b=%0d c=%0d", ok, o.a, o.b, o.c);
    o.b = 4;
    ok = o.randomize();
    $display("randomize(): ok=%0d a=%0d b=%0d c=%0d", ok, o.a, o.b, o.c);
  end
endmodule
