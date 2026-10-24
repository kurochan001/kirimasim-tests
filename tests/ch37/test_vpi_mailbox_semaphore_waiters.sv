/*
:name: test_vpi_mailbox_semaphore_waiters
:description: from the class object of a mailbox, vpiMessages gives every message it holds and vpiWaitingProcesses the threads blocked in get; from that of a semaphore, vpiWaitingProcesses gives the suspended threads of both a static and a dynamic process waiting for a key, and both iterations follow the changes of the mailbox and the semaphore (IEEE 1800-2023 Section 37.33)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.33 37.44 15.3 15.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_mailbox_semaphore_waiters.c
:expected_stdout: @test_vpi_mailbox_semaphore_waiters.expected
*/
// IEEE 1800-2023 §37.33: on the class obj of a mailbox, vpiMessages gives all
// the messages it holds (detail 4), as expressions whose values are read with
// vpi_get_value; on the class obj of a mailbox or a semaphore,
// vpiWaitingProcesses gives the threads (37.44) of the processes suspended
// while waiting for a message or for a key, static and dynamic processes
// alike (detail 3).
//
// At 0, three messages are put into mb_full, the dynamic process of a fork
// branch blocks in get on the empty mb_empty (15.4.5), and both the static
// initial procedure static_waiter and a second fork branch block in get on
// sem, which has no key (15.3.3). At 1 the application finds: mb_full holds
// 10, 20 and 30 and no process waits on it; mb_empty holds nothing and one
// thread waits on it; two different threads wait on sem. Then one message is
// taken from mb_full with try_get, one is put into mb_empty and two keys into
// sem, which lets every waiting process go on, so at 2 mb_full holds 20 and
// 30 and no thread waits on any of the three. The values of the messages are
// printed sorted, since the standard does not fix the order of the
// iteration.
//
// Icarus Verilog 13.0 cannot build the application (its sv_vpi_user.h lacks
// the class object constants of Annex M), and Verilator 5.052 cannot call a
// system task registered by a VPI application.

`timescale 1ns/1ns

module test_vpi_mailbox_semaphore_waiters;
  mailbox #(int) mb_full = new;
  mailbox #(int) mb_empty = new;
  semaphore sem = new(0);
  int taken, received;
  int done;

  initial begin : static_waiter
    sem.get(1);
    done++;
  end

  initial begin
    mb_full.put(10);
    mb_full.put(20);
    mb_full.put(30);
    fork
      begin : mailbox_waiter
        mb_empty.get(received);
        done++;
      end
      begin : semaphore_waiter
        sem.get(1);
        done++;
      end
    join_none
    #1 $vt_wait;
    void'(mb_full.try_get(taken));
    mb_empty.put(5);
    sem.put(2);
    #1 $vt_wait;
    $display("taken %0d, received %0d, processes done %0d", taken, received, done);
  end
endmodule
