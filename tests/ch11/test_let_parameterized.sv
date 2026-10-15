/*
:name: test_let_parameterized
:description: let declarations without and with arguments, nested let calls
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_let_parameterized.expected
*/
// let declarations without and with arguments, and nested let calls (11.12)
module test_let_parameterized;
    // let declarations without arguments
    let MAX_VALUE = 255;
    let MIN_VALUE = 0;
    let MID_VALUE = (MAX_VALUE + MIN_VALUE) / 2;

    // let declarations with arguments
    let in_range(x) = (x >= MIN_VALUE && x <= MAX_VALUE);
    let add(a, b) = a + b;
    let multiply(a, b) = a * b;
    let is_even(n) = (n % 2 == 0);
    let clamp(val, min, max) = (val < min) ? min : ((val > max) ? max : val);

    initial begin
        int test_val;
        int result;

        $display("===== let declaration test =====");

        // let without arguments
        $display("\n[let without arguments]");
        test_val = MAX_VALUE;
        $display("  MAX_VALUE = %d", test_val);
        assert(test_val == 255) else $fatal(1, "FAIL: test_val == 255");

        test_val = MID_VALUE;
        $display("  MID_VALUE = %d", test_val);
        assert(test_val == 127) else $fatal(1, "FAIL: test_val == 127");

        // let with arguments
        $display("\n[let with arguments]");

        // in_range
        $display("  in_range(100) = %b", in_range(100));
        assert(in_range(100) == 1) else $fatal(1, "FAIL: in_range(100) == 1");
        assert(in_range(300) == 0) else $fatal(1, "FAIL: in_range(300) == 0");
        assert(in_range(0) == 1) else $fatal(1, "FAIL: in_range(0) == 1");
        assert(in_range(255) == 1) else $fatal(1, "FAIL: in_range(255) == 1");
        $display("  in_range tests PASSED");

        // add
        result = add(10, 20);
        $display("  add(10, 20) = %d", result);
        assert(result == 30) else $fatal(1, "FAIL: result == 30");

        result = add(100, 155);
        $display("  add(100, 155) = %d", result);
        assert(result == 255) else $fatal(1, "FAIL: result == 255");
        $display("  add tests PASSED");

        // multiply
        result = multiply(5, 6);
        $display("  multiply(5, 6) = %d", result);
        assert(result == 30) else $fatal(1, "FAIL: result == 30");

        result = multiply(12, 12);
        $display("  multiply(12, 12) = %d", result);
        assert(result == 144) else $fatal(1, "FAIL: result == 144");
        $display("  multiply tests PASSED");

        // is_even
        $display("  is_even(4) = %b", is_even(4));
        assert(is_even(4) == 1) else $fatal(1, "FAIL: is_even(4) == 1");
        assert(is_even(5) == 0) else $fatal(1, "FAIL: is_even(5) == 0");
        assert(is_even(100) == 1) else $fatal(1, "FAIL: is_even(100) == 1");
        assert(is_even(101) == 0) else $fatal(1, "FAIL: is_even(101) == 0");
        $display("  is_even tests PASSED");

        // clamp (three arguments)
        result = clamp(50, 0, 100);
        $display("  clamp(50, 0, 100) = %d", result);
        assert(result == 50) else $fatal(1, "FAIL: result == 50");

        result = clamp(-10, 0, 100);
        $display("  clamp(-10, 0, 100) = %d", result);
        assert(result == 0) else $fatal(1, "FAIL: result == 0");  // -10, 0 and 100 are signed, so -10 < 0

        result = clamp(150, 0, 100);
        $display("  clamp(150, 0, 100) = %d", result);
        assert(result == 100) else $fatal(1, "FAIL: result == 100");
        $display("  clamp tests PASSED");

        // nested calls
        $display("\n[nested calls]");
        result = add(multiply(3, 4), multiply(5, 6));
        $display("  add(multiply(3, 4), multiply(5, 6)) = %d", result);
        assert(result == 42) else $fatal(1, "FAIL: result == 42");  // 12 + 30 = 42

        result = clamp(add(100, 200), MIN_VALUE, MAX_VALUE);
        $display("  clamp(add(100, 200), MIN_VALUE, MAX_VALUE) = %d", result);
        assert(result == 255) else $fatal(1, "FAIL: result == 255");  // 300 clamped to 255

        $display("\n===== all let checks done =====");
        $finish;
    end
endmodule
