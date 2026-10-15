/*
:name: test_class_bounded_fifo
:description: A parameterized class FIFO with a size limit, try_put and try_get
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.25 7.10 13.5.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_bounded_fifo.expected
*/
`timescale 1ns/1ps

class bounded_fifo #(type T = int);
    T queue[$];
    int max_size;
    
    function new(int size = 10);
        max_size = size;
    endfunction
    
    function bit try_put(T item);
        if (queue.size() < max_size) begin
            queue.push_back(item);
            return 1;
        end
        return 0;
    endfunction
    
    function bit try_get(ref T item);
        if (queue.size() > 0) begin
            item = queue.pop_front();
            return 1;
        end
        return 0;
    endfunction
    
    function int size();
        return queue.size();
    endfunction
endclass

module test_class_bounded_fifo;
    bounded_fifo#(int) fifo;
    int data;
    bit success;
    
    int fails = 0;

    
    initial begin
        fifo = new(5);
        
        // Put items
        for (int i = 0; i < 5; i++) begin
            success = fifo.try_put(i * 10);
            if (!success) begin fails++; $display("FAIL: put failed"); end
        end
        
        // Try to put when full
        success = fifo.try_put(999);
        if (success) begin fails++; $display("FAIL: should be full"); end
        
        // Get items
        for (int i = 0; i < 5; i++) begin
            success = fifo.try_get(data);
            if (!success || data != i * 10) begin
                begin fails++; $display("FAIL: get failed or wrong data"); end
                $finish;
            end
        end
        
        if (fails == 0) $display("TEST PASSED");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
