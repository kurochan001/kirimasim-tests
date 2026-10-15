/*
:name: test_task_fifo
:description: A FIFO in an unpacked array, written and read by tasks
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3 7.4
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_task_fifo.expected
*/
// A FIFO in an unpacked array, written and read by tasks
module test_task_fifo;
    logic [7:0] fifo[8];
    int wr_ptr, rd_ptr;
    int count;
    logic [7:0] data_out;

    task automatic fifo_write(input logic [7:0] data);
        if (count < 8) begin
            fifo[wr_ptr] = data;
            wr_ptr = (wr_ptr + 1) % 8;
            count++;
            #1;
        end
    endtask

    task automatic fifo_read(output logic [7:0] data);
        if (count > 0) begin
            data = fifo[rd_ptr];
            rd_ptr = (rd_ptr + 1) % 8;
            count--;
            #1;
        end else begin
            data = 8'hxx;
        end
    endtask

    function automatic bit fifo_empty();
        return count == 0;
    endfunction

    function automatic bit fifo_full();
        return count == 8;
    endfunction

    initial begin
        wr_ptr = 0;
        rd_ptr = 0;
        count = 0;

        // Test 1: Fill FIFO
        $display("Test 1: Fill FIFO");
        for (int i = 0; i < 8; i++) begin
            fifo_write(8'(i + 10));
        end
        $display("  Count after fill: %0d", count);
        $display("  Full: %b", fifo_full());

        // Test 2: Read all
        $display("Test 2: Read all");
        for (int i = 0; i < 8; i++) begin
            fifo_read(data_out);
            $display("  Read: %0d", data_out);
        end
        $display("  Empty: %b", fifo_empty());

        // Test 3: Interleaved read/write
        $display("Test 3: Interleaved read/write");
        fifo_write(8'hAA);
        fifo_write(8'hBB);
        fifo_read(data_out);
        $display("  Read: %h", data_out);
        fifo_write(8'hCC);
        fifo_read(data_out);
        $display("  Read: %h", data_out);
        fifo_read(data_out);
        $display("  Read: %h", data_out);

        // Test 4: Wrap-around
        $display("Test 4: Wrap-around");
        for (int i = 0; i < 10; i++) begin
            fifo_write(8'(i));
            if (count > 3) begin
                fifo_read(data_out);
            end
        end
        $display("  Final count: %0d", count);

        $display("");
        $display("TEST PASSED: Task FIFO tests completed");
        $finish;
    end
endmodule
