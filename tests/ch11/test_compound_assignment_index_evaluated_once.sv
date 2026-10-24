/*
:name: test_compound_assignment_index_evaluated_once
:description: each of the twelve compound assignment operators updates its target like the blocking assignment of the corresponding binary operation, evaluating the index expression of the target only once (IEEE 1800-2023 Section 11.4.1)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_compound_assignment_index_evaluated_once.expected
*/
// IEEE 1800-2023 §11.4.1: a op= b, for each of += -= *= /= %= &= |= ^= <<= >>=
// <<<= >>>=, has the meaning of the blocking assignment a = a op b, except
// that an index expression in a is evaluated only once.
// Each line applies one operator to arr[idx()], where idx() counts its calls
// and returns that count: the first call gives 1, a second call would give 2.
// Before each line arr is {0, v, 99, 0}, and the line shows arr[1] and arr[2]
// right after the statement, and the number of calls. With one evaluation of
// the index, arr[1] holds v op b, arr[2] keeps 99 and calls is 1; evaluating
// the index twice would read one element and write the other. The values make
// every operator give a different result; arr is int, so >>= shifts in zeros
// and >>>= copies the sign bit of -16.
// Icarus Verilog 13.0 shifts in zeros for >>>= on an element of an int array
// (1073741820 instead of -4), although arr[1] = arr[1] >>> 2 gives -4 there.

module test_compound_assignment_index_evaluated_once;
  int arr[4];
  int calls;

  function automatic int idx();
    calls++;
    return calls;
  endfunction

  task automatic prep(int v);
    arr = '{0, v, 99, 0};
    calls = 0;
  endtask

  task automatic show(string op);
    $display("%s arr[1]=%0d arr[2]=%0d calls=%0d", op, arr[1], arr[2], calls);
  endtask

  initial begin
    prep(20); arr[idx()] += 5;    show("+=");
    prep(20); arr[idx()] -= 7;    show("-=");
    prep(20); arr[idx()] *= 3;    show("*=");
    prep(20); arr[idx()] /= 6;    show("/=");
    prep(20); arr[idx()] %= 6;    show("%=");
    prep(20); arr[idx()] &= 6;    show("&=");
    prep(20); arr[idx()] |= 6;    show("|=");
    prep(20); arr[idx()] ^= 6;    show("^=");
    prep(20); arr[idx()] <<= 2;   show("<<=");
    prep(-16); arr[idx()] >>= 2;  show(">>=");
    prep(-3); arr[idx()] <<<= 1;  show("<<<=");
    prep(-16); arr[idx()] >>>= 2; show(">>>=");
  end
endmodule
