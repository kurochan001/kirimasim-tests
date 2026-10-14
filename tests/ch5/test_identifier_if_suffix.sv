/*
:name: test_identifier_if_suffix
:description: Identifiers ending in "if" followed by "(" are not the if keyword
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.6 5.6.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_identifier_if_suffix.expected
*/
// Identifiers that end in "if" (set_if, get_if, reset_if, ...) are ordinary
// identifiers, also when "(" follows them. Only the whole word "if" is a
// keyword.
//
// IEEE 1800-2023 5.6, 5.6.2

module test_identifier_if_suffix;

  // Functions with _if suffix (IEEE 1800-2023 §5.6 legal identifiers)
  function automatic int set_if(int index = 0);
    return index + 1;
  endfunction

  function automatic int get_if(int index = 0);
    return index * 2;
  endfunction

  function automatic int reset_if(int value = 0);
    return 0;
  endfunction

  // Functions with other keyword suffixes that should also work
  function automatic int check_for(int count = 0);
    return count;
  endfunction

  function automatic int do_while(int limit = 10);
    return limit;
  endfunction

  // Verify all functions work correctly
  initial begin
    int a, b, c, d, e;

    a = set_if(5);
    b = get_if(3);
    c = reset_if(42);
    d = check_for(7);
    e = do_while(20);

    if (a !== 6) begin
      $display("FAIL: set_if(5) returned %0d, expected 6", a);
      $finish;
    end
    if (b !== 6) begin
      $display("FAIL: get_if(3) returned %0d, expected 6", b);
      $finish;
    end
    if (c !== 0) begin
      $display("FAIL: reset_if(42) returned %0d, expected 0", c);
      $finish;
    end
    if (d !== 7) begin
      $display("FAIL: check_for(7) returned %0d, expected 7", d);
      $finish;
    end
    if (e !== 20) begin
      $display("FAIL: do_while(20) returned %0d, expected 20", e);
      $finish;
    end

    // Also verify standalone if still works
    if (a == 6) begin
      $display("TEST PASSED: identifier _if suffix handled correctly");
    end else begin
      $display("FAIL: standalone if condition broken");
    end
    $finish;
  end

endmodule
