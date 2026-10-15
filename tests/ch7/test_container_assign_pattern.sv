/*
:name: test_container_assign_pattern
:description: Container assignment patterns and type conversion
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10 7.10.4 10.9.1 7.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_container_assign_pattern.expected
*/
// Container assignment patterns and type conversion
module test_container_assign_pattern;
    int pass_count = 0;

    initial begin
        // T1: Queue literal assignment
        begin
            int q[$];
            q = '{1, 2, 3};
            q.push_back(4);
            if (q.size() == 4 && q[3] == 4) begin
                $display("T1: PASS - queue assign then push: size=%0d last=%0d",
                    q.size(), q[3]);
                pass_count++;
            end else
                $display("T1: FAIL - size=%0d", q.size());
        end

        // T2: Queue re-assignment
        begin
            static int q[$] = '{10, 20};
            q = '{30, 40, 50};
            if (q.size() == 3 && q[0] == 30 && q[2] == 50) begin
                $display("T2: PASS - re-assign: size=%0d", q.size());
                pass_count++;
            end else
                $display("T2: FAIL - size=%0d", q.size());
        end

        // T3: Queue assignment from another queue
        begin
            static int a[$] = '{1, 2, 3};
            int b[$];
            b = a;
            b.push_back(4);
            if (a.size() == 3 && b.size() == 4) begin
                $display("T3: PASS - copy independence: a=%0d b=%0d",
                    a.size(), b.size());
                pass_count++;
            end else
                $display("T3: FAIL - a.size=%0d b.size=%0d", a.size(), b.size());
        end

        // T4: Dynamic array new and element assignment
        begin
            int da[];
            da = new[3];
            da[0] = 10;
            da[1] = 20;
            da[2] = 30;
            if (da.size() == 3 && da[0] == 10 && da[2] == 30) begin
                $display("T4: PASS - dynarray: size=%0d vals=%0d,%0d,%0d",
                    da.size(), da[0], da[1], da[2]);
                pass_count++;
            end else
                $display("T4: FAIL - size=%0d", da.size());
        end

        $display("pass_count = %0d", pass_count);
        if (pass_count == 4)
            $display("PASS: test_container_assign_pattern");
        else
            $display("FAIL: test_container_assign_pattern (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
