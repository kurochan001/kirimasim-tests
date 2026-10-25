/*
:name: test_priority_if_listed_order_first_true
:description: A priority-if evaluates its conditions in the order they are written and runs the statement of the first true one when several are true (IEEE 1800-2023 Section 12.4.2)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4.2 12.4.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_priority_if_listed_order_first_true.expected
*/
// IEEE 1800-2023 §12.4.2: the conditions of a priority-if are evaluated in
// the order listed, and when more than one is true the statement of the
// first one runs (the conditions may overlap; that is why priority logic is
// needed). Every chain here ends with an else, so no violation report is due
// when no condition is true.
//
// Each condition is a call cond(id, value), which stores in pos[id] the
// place of its first evaluation (1 for the first condition evaluated, 2 for
// the next, ...). The output shows pos for the conditions up to the first
// true one, which have to be evaluated in that order; whether the later
// conditions are evaluated is not shown.

module test_priority_if_listed_order_first_true;
  int seq;
  int pos [1:3];
  string took;

  function automatic bit cond(int id, bit value);
    seq++;
    if (pos[id] == 0) pos[id] = seq;
    return value;
  endfunction

  task automatic run(bit a, bit b, bit c);
    int last;
    string places;
    seq = 0;
    foreach (pos[i]) pos[i] = 0;
    priority if (cond(1, a)) took = "s1";
    else if (cond(2, b)) took = "s2";
    else if (cond(3, c)) took = "s3";
    else took = "else";
    last = a ? 1 : b ? 2 : 3;
    places = "";
    for (int i = 1; i <= last; i++) places = {places, $sformatf(" %0d", pos[i])};
    $display("%b%b%b: positions of conditions 1..%0d:%s took %s", a, b, c, last, places, took);
  endtask

  initial begin
    run(1, 1, 1);
    run(0, 1, 1);
    run(0, 1, 0);
    run(0, 0, 1);
    run(0, 0, 0);
  end
endmodule
