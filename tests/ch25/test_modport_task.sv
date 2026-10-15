/*
:name: test_modport_task
:description: Test: Modport with task/function
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.5 25.7
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_modport_task.expected
*/
// Test: Modport with task/function
// Tests modport exports of tasks and functions

interface calc_if;
    logic [15:0] operand_a;
    logic [15:0] operand_b;
    logic [15:0] result;
    logic start;
    logic done;

    // Task in interface
    task automatic do_add();
        result = operand_a + operand_b;
        done = 1;
        #1;
        done = 0;
    endtask

    task automatic do_sub();
        result = operand_a - operand_b;
        done = 1;
        #1;
        done = 0;
    endtask

    // Function in interface
    function automatic [15:0] get_max();
        return (operand_a > operand_b) ? operand_a : operand_b;
    endfunction

    function automatic [15:0] get_min();
        return (operand_a < operand_b) ? operand_a : operand_b;
    endfunction

    modport calc_port (
        input operand_a,
        input operand_b,
        output result,
        output done,
        import do_add,
        import do_sub,
        import get_max,
        import get_min
    );

    modport control_port (
        output operand_a,
        output operand_b,
        input result,
        input done,
        output start
    );
endinterface

module calculator(calc_if.calc_port port);
    // Calls a function that the modport imports (25.7)
    function automatic logic [15:0] min_via_port();
        return port.get_min();
    endfunction
endmodule

module test_modport_task;
    calc_if calc_bus();

    calculator calc_unit(calc_bus.calc_port);

    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Initialize
        calc_bus.operand_a = 16'h0000;
        calc_bus.operand_b = 16'h0000;
        calc_bus.start = 0;
        calc_bus.done = 0;
        calc_bus.result = 16'h0000;
        #1;

        // Test 1: Interface task - addition
        calc_bus.operand_a = 16'h0100;
        calc_bus.operand_b = 16'h0050;
        calc_bus.do_add();
        #1;
        if (calc_bus.result == 16'h0150) begin
            $display("PASS: Test 1 - Interface task do_add (0x100 + 0x50 = 0x150)");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - expected 0x0150, got 0x%0h", calc_bus.result);
            fail_count++;
        end

        // Test 2: Interface task - subtraction
        calc_bus.operand_a = 16'h0200;
        calc_bus.operand_b = 16'h0080;
        calc_bus.do_sub();
        #1;
        if (calc_bus.result == 16'h0180) begin
            $display("PASS: Test 2 - Interface task do_sub (0x200 - 0x80 = 0x180)");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - expected 0x0180, got 0x%0h", calc_bus.result);
            fail_count++;
        end

        // Test 3: Interface function - get_max
        calc_bus.operand_a = 16'h00FF;
        calc_bus.operand_b = 16'h0100;
        #1;
        if (calc_bus.get_max() == 16'h0100) begin
            $display("PASS: Test 3 - Interface function get_max");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - expected 0x0100, got 0x%0h", calc_bus.get_max());
            fail_count++;
        end

        // Test 4: Interface function - get_min
        if (calc_bus.get_min() == 16'h00FF && calc_unit.min_via_port() == 16'h00FF) begin
            $display("PASS: Test 4 - Interface function get_min");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - expected 0x00FF, got 0x%0h", calc_bus.get_min());
            fail_count++;
        end

        // Test 5: Chain of operations
        calc_bus.operand_a = 16'h1000;
        calc_bus.operand_b = 16'h0234;
        calc_bus.do_add();
        #1;
        calc_bus.operand_a = calc_bus.result;
        calc_bus.operand_b = 16'h0100;
        calc_bus.do_sub();
        #1;
        if (calc_bus.result == 16'h1134) begin
            $display("PASS: Test 5 - Chain of operations (1000+234-100 = 1134)");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - expected 0x1134, got 0x%0h", calc_bus.result);
            fail_count++;
        end

        $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
        if (fail_count == 0)
            $display("PASS: All modport task/function tests passed");
        else
            $display("FAIL: Some tests failed");
        $finish;
    end
endmodule
