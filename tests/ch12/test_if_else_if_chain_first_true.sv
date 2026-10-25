/*
:name: test_if_else_if_chain_first_true
:description: An if-else-if chain evaluates its conditions in order, runs only the statement of the first true one and evaluates no later condition; the final else runs when none is true, and without it nothing runs (IEEE 1800-2023 Section 12.4.1)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4.1 12.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_if_else_if_chain_first_true.expected
*/
// IEEE 1800-2023 §12.4.1: the conditions of an if-else-if construct are
// evaluated in order; the statement of the first true condition runs, and
// that ends the whole construct. The last else handles the case where no
// condition was true; it can be left out, and then nothing runs.
//
// Each condition is a call cond(id, value) that appends its id to "order"
// before returning the value, so the output shows which conditions were
// evaluated and in which order. Several conditions are true at once to show
// that only the first true one counts and that the later ones are not
// evaluated. The chain without a final else leaves "took" at "none".

module test_if_else_if_chain_first_true;
  string order;
  string took;

  function automatic bit cond(int id, bit value);
    order = {order, $sformatf("%0d", id)};
    return value;
  endfunction

  task automatic with_else(bit a, bit b, bit c);
    order = "";
    took = "none";
    if (cond(1, a)) took = "s1";
    else if (cond(2, b)) begin
      took = "s2";
      order = {order, "+"};
    end
    else if (cond(3, c)) took = "s3";
    else took = "default";
    $display("with else    %b%b%b: evaluated %s took %s", a, b, c, order, took);
  endtask

  task automatic without_else(bit a, bit b, bit c);
    order = "";
    took = "none";
    if (cond(1, a)) took = "s1";
    else if (cond(2, b)) took = "s2";
    else if (cond(3, c)) took = "s3";
    $display("without else %b%b%b: evaluated %s took %s", a, b, c, order, took);
  endtask

  initial begin
    with_else(1, 1, 1);
    with_else(0, 1, 1);
    with_else(0, 0, 1);
    with_else(0, 0, 0);
    without_else(0, 1, 0);
    without_else(0, 0, 1);
    without_else(0, 0, 0);
  end
endmodule
