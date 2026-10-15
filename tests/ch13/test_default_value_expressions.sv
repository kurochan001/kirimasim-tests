/*
:name: test_default_value_expressions
:description: Default Argument Values
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5.3 13.5.4
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_default_value_expressions.expected
*/
// IEEE 1800-2023 Section 13.5.1: Default Argument Values
// Tests complex default value expressions in function/task arguments

module test_default_value_expressions;
    int pass_count = 0;
    int fail_count = 0;

    parameter int DEFAULT_SIZE = 10;
    parameter string DEFAULT_NAME = "default";

    // Test 1: Simple default values
    function automatic int add_with_default(int a, int b = 0);
        return a + b;
    endfunction

    // Test 2: Multiple defaults
    function automatic int multi_default(int a = 1, int b = 2, int c = 3);
        return a + b + c;
    endfunction

    // Test 3: Default using parameter
    function automatic int sized_array_sum(int size = DEFAULT_SIZE);
        int sum = 0;
        for (int i = 0; i < size; i++) sum += i;
        return sum;
    endfunction

    // Test 4: String default
    function automatic string greet(string name = DEFAULT_NAME);
        return {"Hello, ", name};
    endfunction

    // Test 5: Expression as default. The default is evaluated in the scope
    // that contains the declaration (here the module) on each call that uses
    // it (13.5.3), so it sees the current value of scale.
    int scale = 2;
    function automatic int expr_default(int n, int k = scale * 10);
        return n + k;
    endfunction

    // Test 7: Struct with default
    typedef struct {
        int x;
        int y;
    } point_t;

    function automatic point_t move_point(point_t p, int dx = 0, int dy = 0);
        p.x += dx;
        p.y += dy;
        return p;
    endfunction

    // Test 8: Mixed required and default
    function automatic int mixed_args(int required, int opt1 = 10, string opt2 = "test");
        return required + opt1 + opt2.len();
    endfunction

    // Test 9: Task with default
    int task_result;
    task automatic task_with_default(input int val = 100, output int result);
        result = val * 2;
    endtask

    initial begin
        int r;
        point_t pt;

        // Test 1: Simple default
        if (add_with_default(5) == 5 && add_with_default(5, 3) == 8) pass_count++;
        else begin fail_count++; $display("FAIL: simple default"); end

        // Test 2: Multiple defaults
        if (multi_default() == 6 && multi_default(10) == 15 && multi_default(10, 20) == 33)
            pass_count++;
        else begin fail_count++; $display("FAIL: multi default"); end

        // Test 3: Parameter default
        if (sized_array_sum() == 45 && sized_array_sum(5) == 10) pass_count++;  // 0+1+2+...+9=45, 0+1+2+3+4=10
        else begin fail_count++; $display("FAIL: param default"); end

        // Test 4: String default
        if (greet() == "Hello, default" && greet("World") == "Hello, World")
            pass_count++;
        else begin fail_count++; $display("FAIL: string default"); end

        // Test 5: Expression default, evaluated again on each call
        r = expr_default(5);
        scale = 3;
        if (r == 25 && expr_default(5) == 35 && expr_default(5, 1) == 6) pass_count++;
        else begin fail_count++; $display("FAIL: expr default"); end

        // Test 6: An empty argument stands for the default (13.5.3)
        if (multi_default(, 20) == 24 && multi_default(, , 30) == 33) pass_count++;
        else begin fail_count++; $display("FAIL: empty argument"); end

        // Test 7: Struct default args
        pt = '{10, 20};
        pt = move_point(pt);  // no change
        if (pt.x == 10 && pt.y == 20) pass_count++;
        else begin fail_count++; $display("FAIL: struct default no move"); end
        pt = move_point(pt, 5);  // x+5
        if (pt.x == 15 && pt.y == 20) pass_count++;
        else begin fail_count++; $display("FAIL: struct default partial"); end

        // Test 8: Mixed required and default
        if (mixed_args(100) == 114 && mixed_args(100, 5, "ab") == 107) pass_count++;
        else begin fail_count++; $display("FAIL: mixed args"); end

        // Test 9: Task with default
        task_with_default(.result(task_result));
        if (task_result == 200) pass_count++;
        else begin fail_count++; $display("FAIL: task default"); end
        task_with_default(50, task_result);
        if (task_result == 100) pass_count++;
        else begin fail_count++; $display("FAIL: task explicit"); end

        if (fail_count == 0 && pass_count == 11)
            $display("TEST PASSED (%0d/11)", pass_count);
        else
            $display("TEST FAILED (pass=%0d, fail=%0d)", pass_count, fail_count);
        $finish;
    end
endmodule
