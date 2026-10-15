/*
:name: test_function_in_assertion
:description: Functions called in immediate and concurrent assertion expressions
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4 16.6 16.14
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_in_assertion.expected
*/
// IEEE 1800-2023 Section 13.4 + 16: Functions in Assertions
// Tests function calls within assertion expressions

module test_function_in_assertion;
    int pass_count = 0;
    int fail_count = 0;

    logic clk = 0;
    logic [7:0] data;
    logic valid;

    always #5 clk = ~clk;

    // Helper functions for assertions
    function automatic bit is_valid_data(logic [7:0] d);
        return (d != 8'h00) && (d != 8'hFF);
    endfunction

    function automatic bit check_range(logic [7:0] d, int min_val, int max_val);
        return (d >= min_val) && (d <= max_val);
    endfunction

    function automatic int count_ones(logic [7:0] d);
        int cnt = 0;
        for (int i = 0; i < 8; i++)
            if (d[i]) cnt++;
        return cnt;
    endfunction

    function automatic bit is_power_of_two(logic [7:0] d);
        return (d != 0) && ((d & (d - 1)) == 0);
    endfunction

    // Immediate assertions with functions
    task check_immediate_assertions();
        // Test with valid data
        data = 8'h55;
        assert(is_valid_data(data)) else begin
            fail_count++;
            $display("FAIL: is_valid_data immediate");
        end
        pass_count++;

        // Test range check
        data = 8'h40;
        assert(check_range(data, 8'h20, 8'h80)) else begin
            fail_count++;
            $display("FAIL: check_range immediate");
        end
        pass_count++;

        // Test count ones
        data = 8'b10101010;  // 4 ones
        assert(count_ones(data) == 4) else begin
            fail_count++;
            $display("FAIL: count_ones immediate");
        end
        pass_count++;

        // Test power of two
        data = 8'h10;  // 16 = 2^4
        assert(is_power_of_two(data)) else begin
            fail_count++;
            $display("FAIL: is_power_of_two immediate");
        end
        pass_count++;
    endtask

    // Properties using functions
    property p_valid_when_enabled;
        @(posedge clk) valid |-> is_valid_data(data);
    endproperty

    property p_data_in_range;
        @(posedge clk) valid |-> check_range(data, 8'h01, 8'hFE);
    endproperty

    property p_ones_count;
        @(posedge clk) valid |-> (count_ones(data) >= 2);
    endproperty

    // Concurrent assertion instances
    assert property (p_valid_when_enabled)
        else begin fail_count++; $display("Concurrent: valid data check failed"); end

    assert property (p_data_in_range)
        else begin fail_count++; $display("Concurrent: range check failed"); end

    initial begin
        valid = 0;
        data = 8'h00;

        // Run immediate assertion tests
        check_immediate_assertions();

        // Test concurrent assertions
        @(posedge clk);

        // Valid scenario - should pass concurrent assertions
        valid = 1;
        data = 8'h55;
        @(posedge clk);
        @(posedge clk);

        // Another valid scenario
        data = 8'h3C;
        @(posedge clk);
        @(posedge clk);

        // Disable and finish
        valid = 0;
        repeat(3) @(posedge clk);

        if (fail_count == 0)
            $display("TEST PASSED (%0d tests)", pass_count);
        else
            $display("TEST FAILED (pass=%0d, fail=%0d)", pass_count, fail_count);
        $finish;
    end
endmodule
