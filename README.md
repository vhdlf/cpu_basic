Design of a pentium-like 32-bit CPU.

> Written while studying the course Advanced Computer architecture at IIIT Hyderabad,
> by professor R. Govindarajulu. This is a turing-complete 32-bit CPU with data movement,
> branch, arithmetic, and logical instructions. It follows the instruction format of
> Intel x86 processors, where each instruction takes 2 register operands and an optional
> immediate value. Like x86, this has 16 32-bit registers, a flag register, and an
> instruction pointer. The memory address is made to be 16-bit for simulation purposes.

> Wrote this after following:<br>
> gardintrapp/cpu_4004 by Oddbjorn Norstrand<br>
> Thank you.



## synthesis

![design-file](docs/design-file.png)

![compile-design](docs/compile-design.png)

![rtl](docs/rtl.png)

![technology-map](docs/technology-map.png)

![resource-properties](docs/resource-properties.png)

![pin-plan](docs/pin-plan.png)

![chip-plan](docs/chip-plan.png)

![assignment-settings](docs/assignment-settings.png)

![simulation-library-compiler](docs/simulation-library-compiler.png)



## design

![design-pkg-bits](docs/design-pkg-bits.png)

![design-pkg-mem](docs/design-pkg-mem.png)

![design-pkg-cpu](docs/design-pkg-cpu.png)

![design-pkg-cpu-opcodes](docs/design-pkg-cpu-opcodes.png)

![design-pkg-cpu-output](docs/design-pkg-cpu-output.png)

![design-top-entity](docs/design-top-entity.png)

![design-top-reset](docs/design-top-reset.png)

![design-top-run](docs/design-top-run.png)

![design-top-run-drive](docs/design-top-run-drive.png)

![design-top-st-halted](docs/design-top-st-halted.png)

![design-top-st-fetch](docs/design-top-st-fetch.png)

![design-top-st-load-store](docs/design-top-st-load-store.png)

![design-top-op-p1](docs/design-top-op-p1.png)

![design-top-op-p2](docs/design-top-op-p2.png)

![design-top-op-p3](docs/design-top-op-p3.png)

![design-top-op-p4](docs/design-top-op-p4.png)



## testbench

![testbench-signals](docs/testbench-signals.png)

![testbench-clk-mem](docs/testbench-clk-mem.png)

![testbench-test-square](docs/testbench-test-square.png)

![testbench-test-factorial](docs/testbench-test-factorial.png)

![testbench-test-prime](docs/testbench-test-prime.png)

![testbench-test-prime2](docs/testbench-test-prime2.png)



## simulation

![simulation](docs/simulation.png)

![simulation01-memory-init](docs/simulation01-memory-init.png)

![simulation02-cpu-reset](docs/simulation02-cpu-reset.png)

![simulation03-execute-not-started](docs/simulation03-execute-not-started.png)

![simulation04-memory-output](docs/simulation04-memory-output.png)

![simulation05-memory-input](docs/simulation05-memory-input.png)

![simulation06-test-factorial](docs/simulation06-test-factorial.png)

![simulation07-test-prime](docs/simulation07-test-prime.png)



## report

![ghdl-square](docs/ghdl-square.png)

![ghdl-factorial](docs/ghdl-factorial.png)

![ghdl-prime](docs/ghdl-prime.png)

![ghdl-prime2](docs/ghdl-prime2.png)
