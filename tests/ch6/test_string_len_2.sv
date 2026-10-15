/*
:name: test_string_len_2
:description: String len method
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_len_2.expected
*/
// String len method
module test_string_len;
    string s;
    int passed = 0;
    int failed = 0;

    initial begin
        // Test 1: Empty string length
        s = "";
        if (s.len() == 0) begin
            $display("Test 1 PASS: empty string len");
            passed++;
        end else begin
            $display("Test 1 FAIL: empty string len, got %0d", s.len());
            failed++;
        end

        // Test 2: Single character
        s = "a";
        if (s.len() == 1) begin
            $display("Test 2 PASS: single char len");
            passed++;
        end else begin
            $display("Test 2 FAIL: single char len");
            failed++;
        end

        // Test 3: Multiple characters
        s = "hello";
        if (s.len() == 5) begin
            $display("Test 3 PASS: hello len");
            passed++;
        end else begin
            $display("Test 3 FAIL: hello len");
            failed++;
        end

        // Test 4: String with spaces
        s = "hello world";
        if (s.len() == 11) begin
            $display("Test 4 PASS: string with space len");
            passed++;
        end else begin
            $display("Test 4 FAIL: string with space len");
            failed++;
        end

        // Test 5: Longer string
        s = "SystemVerilog Test";
        if (s.len() == 18) begin
            $display("Test 5 PASS: longer string len");
            passed++;
        end else begin
            $display("Test 5 FAIL: longer string len, got %0d", s.len());
            failed++;
        end

        if (failed == 0)
            $display("PASS: All %0d tests passed", passed);
        else
            $display("FAIL: %0d passed, %0d failed", passed, failed);

        $finish;
    end
endmodule
