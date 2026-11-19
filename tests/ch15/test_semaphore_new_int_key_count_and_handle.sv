/*
:name: test_semaphore_new_int_key_count_and_handle
:description: semaphore new() takes an int key count that defaults to 0, so a 33-bit argument is cut to its low 32 bits and a negative count is kept, and each call returns a handle to a new semaphore (IEEE 1800-2023 Section 15.3.1)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.3.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_semaphore_new_int_key_count_and_handle.expected
*/
// IEEE 1800-2023 §15.3.1: the prototype of new() is a function with one int
// argument, the initial number of keys, whose default is 0; the count may be
// negative, and new() returns the handle of the semaphore it creates.
//
// The keys of a semaphore are counted by taking them one at a time with
// try_get(1) until it fails, at most ten times. new without an argument
// gives 0 keys. new(-2) gives 0 keys to take, and put(3) then leaves exactly
// one, which only a signed count of -2 gives. The argument 33'h1_0000_0003
// is converted to int as in an assignment, so the semaphore has 3 keys; a
// count of more than 32 bits would keep 4294967299 keys and the count would
// stop at the bound 10. A handle declared with new(5) as its initial value
// has 5 keys. Two calls of new() give two different non-null handles.
// Icarus Verilog 13.0 does not know the semaphore type.

module test_semaphore_new_int_key_count_and_handle;
  semaphore s_def, s_neg, s_wide, s_a, s_b;
  semaphore s_decl = new(5);
  bit differ, not_null;

  function automatic int keys(semaphore s);
    int n = 0;
    repeat (10) begin
      if (s.try_get(1) > 0) n++;
      else break;
    end
    return n;
  endfunction

  initial begin
    s_def = new;
    $display("new: %0d keys", keys(s_def));
    s_neg = new(-2);
    $display("new(-2): %0d keys", keys(s_neg));
    s_neg.put(3);
    $display("new(-2), put(3): %0d keys", keys(s_neg));
    s_wide = new(33'h1_0000_0003);
    $display("new(33'h1_0000_0003): %0d keys", keys(s_wide));
    $display("declared with new(5): %0d keys", keys(s_decl));
    s_a = new(1);
    s_b = new(1);
    differ = s_a != s_b;
    not_null = s_a != null && s_b != null;
    $display("two new(1) handles: different %0d, not null %0d", differ, not_null);
  end
endmodule
