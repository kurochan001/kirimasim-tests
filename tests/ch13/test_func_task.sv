/*
:name: test_func_task
:description: Pure function
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3 13.4 13.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_func_task.expected
*/
module test_func_task;
    int pass_count = 0;
    int test_count = 0;
    
    // Pure function
    function automatic int add(int a, int b);
        return a + b;
    endfunction
    
    // Function with local var
    function automatic int factorial(int n);
        int result = 1;
        for (int i = 1; i <= n; i++)
            result *= i;
        return result;
    endfunction
    
    // Recursive function
    function automatic int fib(int n);
        if (n <= 1) return n;
        return fib(n-1) + fib(n-2);
    endfunction
    
    // Function with output
    function automatic void swap(ref int a, ref int b);
        int temp = a;
        a = b;
        b = temp;
    endfunction
    
    // Task with delay
    task automatic delay_task(input int cycles, output int result);
        result = 0;
        repeat (cycles) begin
            #1;
            result++;
        end
    endtask
    
    // Task with inout
    task automatic increment(inout int val, input int amount);
        val += amount;
    endtask
    
    int a, b, result;
    
    initial begin
        // Test 1: Simple function call
        test_count++;
        if (add(3, 4) == 7) pass_count++;
        
        // Test 2: Factorial
        test_count++;
        if (factorial(5) == 120) pass_count++;
        
        // Test 3: Fibonacci
        test_count++;
        if (fib(10) == 55) pass_count++;
        
        // Test 4: Swap function
        test_count++;
        a = 10;
        b = 20;
        swap(a, b);
        if (a == 20 && b == 10) pass_count++;
        
        // Test 5: Nested function calls
        test_count++;
        if (add(add(1, 2), add(3, 4)) == 10) pass_count++;
        
        // Test 6: Function in expression
        test_count++;
        result = factorial(3) * 2;
        if (result == 12) pass_count++;
        
        // Test 7: Task call
        test_count++;
        delay_task(5, result);
        if (result == 5) pass_count++;
        
        // Test 8: Task with inout
        test_count++;
        a = 100;
        increment(a, 50);
        if (a == 150) pass_count++;
        
        // Test 9: Function as condition
        test_count++;
        if (add(1, 1) == 2) pass_count++;
        
        // Test 10: Zero arguments
        test_count++;
        if (factorial(0) == 1) pass_count++;
        
        if (pass_count == test_count)
            $display("TEST PASSED: %0d/%0d", pass_count, test_count);
        else
            $display("TEST FAILED: %0d/%0d", pass_count, test_count);
        $finish;
    end
endmodule
