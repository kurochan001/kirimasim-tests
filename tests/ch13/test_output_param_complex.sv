/*
:name: test_output_param_complex
:description: Output parameter writeback to array elements and members
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5 13.5.1
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_output_param_complex.expected
*/
// IEEE 1800-2023 §13.3: Output parameter writeback to array elements and members
module test_output_param_complex;

    typedef struct {
        int x;
        int y;
    } point_t;

    // Function with output parameter
    function void swap_values(input int a, output int b);
        b = a * 2;
    endfunction

    function void compute_point(input int scale, output int result);
        result = scale + 100;
    endfunction

    int arr[4];
    point_t pt;
    int pass_count = 0;
    int fail_count = 0;
    int test_count = 0;

    task check_int(string test_name, int actual, int expected);
        test_count++;
        if (actual == expected) begin
            pass_count++;
        end else begin
            fail_count++;
            $display("FAIL: %s - expected %0d, got %0d", test_name, expected, actual);
        end
    endtask

    initial begin
        // Test 1: Output parameter to simple variable (baseline)
        int simple_out;
        swap_values(5, simple_out);
        check_int("simple_output", simple_out, 10);

        // Test 2: Output parameter to array element
        arr[0] = 0;
        arr[1] = 0;
        swap_values(7, arr[1]);
        check_int("array_element_output", arr[1], 14);

        // Test 3: Output parameter to struct member
        pt.x = 0;
        pt.y = 0;
        compute_point(50, pt.x);
        check_int("struct_member_output", pt.x, 150);

        // Summary
        $display("=== Output Parameter Complex Tests ===");
        $display("Tests: %0d, Pass: %0d, Fail: %0d", test_count, pass_count, fail_count);

        if (fail_count == 0)
            $display("PASS: All %0d tests passed", test_count);
        else
            $display("FAIL: %0d tests failed", fail_count);

        $finish;
    end
endmodule
