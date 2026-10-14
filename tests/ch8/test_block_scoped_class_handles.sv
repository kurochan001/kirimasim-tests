/*
:name: test_block_scoped_class_handles
:description: Class handles declared in begin-end blocks, one hiding a module-level handle (IEEE 1800-2023 Sections 8.4 and 23.9)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.4 23.9 9.3.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_block_scoped_class_handles.expected
*/
// Class handles declared in begin-end blocks, including one that hides a
// module-level handle of the same name (IEEE 1800-2023 Sections 8.4 and 23.9)
module test_block_scoped_class_handles;
    int pass_count = 0;

    class Counter;
        int count;

        function new(int init = 0);
            count = init;
        endfunction

        function void increment();
            count++;
        endfunction

        function int get();
            return count;
        endfunction

        function void add(int val);
            count += val;
        endfunction
    endclass

    // Module-level counter
    Counter c;

    initial begin
        c = new(100);

        // T1: Block-scoped class instance with same name
        begin
            Counter c;
            c = new(0);
            c.increment();
            c.increment();
            c.increment();
            if (c.get() == 3) begin
                $display("T1: PASS - block c.get() = %0d", c.get());
                pass_count++;
            end else
                $display("T1: FAIL - c.get() = %0d", c.get());
        end

        // T2: Module-level counter unchanged
        if (c.get() == 100) begin
            $display("T2: PASS - module c.get() = %0d", c.get());
            pass_count++;
        end else
            $display("T2: FAIL - c.get() = %0d", c.get());

        // T3: Multiple block-scoped counters
        begin
            Counter a, b;
            a = new(10);
            b = new(20);
            a.add(5);
            b.add(10);
            if (a.get() == 15 && b.get() == 30) begin
                $display("T3: PASS - a=%0d b=%0d", a.get(), b.get());
                pass_count++;
            end else
                $display("T3: FAIL - a=%0d b=%0d", a.get(), b.get());
        end

        // T4: Same name in different blocks
        begin
            Counter obj;
            obj = new(50);
            obj.add(25);
            if (obj.get() == 75) begin
                $display("T4a: PASS - obj=%0d", obj.get());
            end
        end
        begin
            Counter obj;
            obj = new(1000);
            obj.add(234);
            if (obj.get() == 1234) begin
                $display("T4b: PASS - obj=%0d", obj.get());
                pass_count++;
            end else
                $display("T4: FAIL - obj=%0d", obj.get());
        end

        // T5: Chained method calls
        begin
            Counter tmp;
            tmp = new(0);
            tmp.increment();
            tmp.increment();
            tmp.add(tmp.get());  // 2 + 2 = 4
            if (tmp.get() == 4) begin
                $display("T5: PASS - chained: %0d", tmp.get());
                pass_count++;
            end else
                $display("T5: FAIL - tmp=%0d", tmp.get());
        end

        // Summary
        $display("pass_count = %0d", pass_count);
        if (pass_count == 5)
            $display("PASS: test_block_scoped_class_handles");
        else
            $display("FAIL: test_block_scoped_class_handles (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
