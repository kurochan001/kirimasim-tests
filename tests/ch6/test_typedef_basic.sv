/*
:name: test_typedef_basic
:description: Typedef Tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.18
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_typedef_basic.expected
*/
// IEEE 1800-2023 Section 6.18 - Typedef Tests
module test_typedef_basic;
    int pass_count = 0;
    int fail_count = 0;

    typedef int my_int;
    typedef logic [7:0] byte_t;
    typedef logic [15:0] word_t;
    typedef int arr_t[4];
    typedef string my_string;

    initial begin
        my_int mi;
        byte_t b;
        word_t w;
        arr_t a;
        my_string s;

        $display("=== IEEE 1800-2023 Typedef Tests ===");

        // Test 1: Int typedef
        $display("Test 1: Int typedef");
        mi = 42;
        if (mi == 42) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", mi); fail_count++; end

        // Test 2: Byte typedef
        $display("Test 2: Byte typedef");
        b = 8'hAB;
        if (b == 8'hAB) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %h", b); fail_count++; end

        // Test 3: Word typedef
        $display("Test 3: Word typedef");
        w = 16'h1234;
        if (w == 16'h1234) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %h", w); fail_count++; end

        // Test 4: Array typedef
        $display("Test 4: Array typedef");
        a = '{1, 2, 3, 4};
        if (a[2] == 3) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", a[2]); fail_count++; end

        // Test 5: String typedef
        $display("Test 5: String typedef");
        s = "hello";
        if (s == "hello") begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL"); fail_count++; end

        // Test 6: Operations
        $display("Test 6: Operations");
        mi = 10;
        mi = mi + 5;
        if (mi == 15) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", mi); fail_count++; end

        // Test 7: Byte ops
        $display("Test 7: Byte ops");
        b = 8'hF0;
        b = b | 8'h0F;
        if (b == 8'hFF) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %h", b); fail_count++; end

        // Test 8: Word ops
        $display("Test 8: Word ops");
        w = 16'h00FF;
        w = w << 8;
        if (w == 16'hFF00) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %h", w); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
