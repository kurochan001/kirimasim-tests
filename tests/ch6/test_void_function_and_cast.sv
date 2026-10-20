/*
:name: test_void_function_and_cast
:description: A function with the void return type returns no value and is called as a statement, and casting a function call to void discards its result (IEEE 1800-2023 Section 6.13)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.13 13.4.1 6.24.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_void_function_and_cast.expected
*/
// IEEE 1800-2023 §6.13: void stands for nonexistent data and can be the return
// type of a function that returns no value, which is called as a statement
// (13.4.1). A function that does return a value can still be called for its
// side effects with its result cast to void (6.24.1). bump adds to count and
// returns nothing; next_id returns a value that the cast drops.

module test_void_function_and_cast;
  int count = 0;

  function void bump(int by);
    count += by;
  endfunction

  function int next_id();
    count += 10;
    return count;
  endfunction

  initial begin
    bump(2);
    bump(3);
    void'(next_id());
    $display("count=%0d", count);
  end
endmodule
