/*
:name: test_randomize_failure_keeps_values
:description: When randomize() or std::randomize() fails, it returns 0, the random variables keep their values, and post_randomize is not called (IEEE 1800-2023 Section 18.6.3)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.6.3 18.6.2 18.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randomize_failure_keeps_values.expected
*/
// IEEE 1800-2023 §18.6.3: when the constraints cannot be met, randomize()
// returns 0, the random variables keep their previous values, and
// post_randomize() (18.6.2) is not called. §18.12: std::randomize() behaves the
// same way as the randomize() method of a class, so after a failure the scope
// variables keep their values too.
//
// After the failure, version 5.052 of Verilator calls post_randomize and
// changes the variable passed to std::randomize; Icarus Verilog 13.0 does not
// compile classes with constraints.

class rfk_obj;
  rand bit [3:0] p;
  int post_calls;
  constraint c { p == 4'd5; }
  function void post_randomize();
    post_calls++;
  endfunction
endclass

module test_randomize_failure_keeps_values;
  rfk_obj o;
  int ok;
  int a;

  initial begin
    o = new;
    ok = o.randomize();
    $display("first: ok=%0d p=%0d post_calls=%0d", ok, o.p, o.post_calls);
    ok = o.randomize() with { p == 4'd6; };
    $display("contradiction: ok=%0d p=%0d post_calls=%0d", ok, o.p, o.post_calls);
    a = 4;
    ok = std::randomize(a) with { a > 5; a < 3; };
    $display("std::randomize contradiction: ok=%0d a=%0d", ok, a);
  end
endmodule
