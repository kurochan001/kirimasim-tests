/*
:name: test_default_argument_only_when_omitted
:description: The default expression of a subroutine argument is evaluated only for calls that leave the argument out, once for each such call, and not when an actual argument is given by position or by name (IEEE 1800-2023 Section 13.5.3)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5.3 13.5.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_default_argument_only_when_omitted.expected
*/
// IEEE 1800-2023 §13.5.3: when a call gives an actual argument for a formal
// that has a default, the default expression is not evaluated; when the
// argument is left out, the default expression is evaluated for that call.
//
// The default of id is next_id(), which counts its calls and returns
// 100 + count. The calls give id by position (5), by name (9) and leave it
// out, in an order that shows each omitted call evaluating the default once
// more and each call with an actual leaving the count unchanged.

module test_default_argument_only_when_omitted;
  int calls;
  int got;

  function automatic int next_id();
    calls++;
    return 100 + calls;
  endfunction

  task automatic use_id(output int seen, input int id = next_id());
    seen = id;
  endtask

  initial begin
    calls = 0;
    use_id(got, 5);
    $display("use_id(got, 5): got=%0d calls=%0d", got, calls);
    use_id(got);
    $display("use_id(got): got=%0d calls=%0d", got, calls);
    use_id(.seen(got), .id(9));
    $display("use_id(.seen(got), .id(9)): got=%0d calls=%0d", got, calls);
    use_id(.seen(got));
    $display("use_id(.seen(got)): got=%0d calls=%0d", got, calls);
    use_id(got, 7);
    $display("use_id(got, 7): got=%0d calls=%0d", got, calls);
  end
endmodule
