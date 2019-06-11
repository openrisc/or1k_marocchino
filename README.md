# *or1k_marocchino* - OpenRISC processor IP core based on Tomasulo algorithm

## The Basics

This repository contains an OpenRISC 1000 compliant processor IP core.
The core:
 1) Implements a variant of Tomasulo algorithm
 2) Supports single and double precision floating point instructions
 3) Has got separate CPU and Wishbone clocks assuming that
    CPU clock could be great or equal to Wishbone one but they
    must be aligned
 4) Supports atomic instructions (load linked / store conditional)
 5) Supports data bus snoop and shadow registers set for multicore systems

It is written in Verilog HDL.

This repository only contains the IP source code and some documentation. For
a verification environment, please see other projects.  See some details below.

## License

This project is licensed under the Open Hardware Description License (OHDL). For
details please see the [LICENSE](./LICENSE) file or http://juliusbaxter.net/ohdl/

## Style guide for contribution

  1) TABs are forbidden, only SPACEs are allowed
  2) Use 2 SPACEs as indent
  3) Use Verilog 200x style for modules declarations
  4) Use `_i` and `_o` suffixes in input/output names (inherited from mor1kx)
  5) Do not include Emacs AUTO_TEMPLATEs
  6) Use alignment for declarations (for inputs, outputs, wires, etc) as it done in original sources
  7) Align position of `=` and `<=` in adjacently places equations as it done in original sources
  8) Always use begin/end for `always @()` process, but they could be omitted for single equation in `if` branches.
  9) Separate `()` from `if`, `case`, etc with one SPACE (inherited from mor1kx)
 10) Don’t include files if you don’t use things from inclusions
 11) Don’t use timescale (inherited from mor1kx)
 12) In general: try to keep nice appearance of MAROCCHINO sources by following the format of already written code

## Testing and Continuous Integration

A CPU core cannot be trusted without a full set of verification testing.  The
`or1k_marocchino` is constantly verified for correctness with the or1k Continuous
Integration (CI) suite running in travis ci. This currently covers:

 - source linting - a `verilator --lint-only` check is run on each commit to
   ensure there are no code quality issues.
 - [or1k-tests](https://github.com/openrisc/or1k-tests) - the `or1k-tests` test suite
   is run against different configurations to check most major instructions,
   exception handling, caching, timers, interrupts and other features.

   Status: [![Build Status](https://travis-ci.org/openrisc/or1k_marocchino.svg?branch=master)](https://travis-ci.org/openrisc/or1k_marocchino)

[Librecores-CI](https://github.com/librecores/docker-images/tree/master/librecores-ci) docker image is used for testing and continous integration. Librecores CI image includes many common EDA tools such as Icarus Verilog, Verilator, Yosys and also target the FuseSoC use cases. In the travis flow `or1k-test` runs inside a Librecores-CI docker container.

In the future we are working on bringing more tests including:

  - softfloat, fpu verification (may not be feasable in CI due to long run times)
  - Resource utilization regression with yosys synth_intel synth_xilinx
  - Formal verification with yosys
  - Verification that each revision can boot differnt OS's **Linux**, **RTMES**
  - Golden reference `or1ksim` trace comparisons vs verilog model using constrained
    random inputs.

## Configuration

MAROCCHINO is complete re-write of mor1kx CAPPUCCINO. As a result MAROCCHINO had inherited most of configuration options.
At the same time a lot of original options were made permanently defined to reduce complexity. 
The following tables explain how each parameter can be configured,
what the configuration does and why you might want to use it.

**Note 1:** *Permanently defined options have got default value but `Values` field is filled with `n/a`
that indicates that they are not presence among MAROCCHINO parameters.*

**Note 2:** *The **Comments** field below also could indicates if a certain application (such
as running Linux) requires a setting different than the default value.*

### Basic parameters

|Parameter|Description|Default|Values|Comments|
|---------|-----------|-------|------|--------|
|OPTION_OPERAND_WIDTH|Specify the CPU data and address widths|32|32|Do not specify value other than `32`. Actually the parametrization is incomplete.|
|OPTION_RESET_PC|Specify the program counter upon reset|`0x100`|n| |

### Caching parameters

|Parameter|Description|Default|Values|Comments|
|---------|-----------|-------|------|--------|
|FEATURE_DATACACHE|Enable memory access data caching|`ENABLED`|`n/a`|It presences permanently|
|OPTION_DCACHE_BLOCK_WIDTH|Specify the address width of a cache block|5|5, 4|see notes below|
|OPTION_DCACHE_SET_WIDTH|Specify the set address width|8|`n`|see notes below|
|OPTION_DCACHE_WAYS|Specify the number of blocks per set|2|`n`| |
|OPTION_DCACHE_LIMIT_WIDTH|Specify the maximum address width|32|`n`|`31` for Linux to allow uncached device access|
|OPTION_DCACHE_SNOOP|Enable bus snooping for cache coherency|`NONE`|`ENABLED` `NONE`|Linux SMP|
|OPTION_DCACHE_CLEAR_ON_INIT|Clean up DCACHE RAM blocks at simulation start|0|0, 1|see notes below|
|FEATURE_INSTRUCTIONCACHE|Enable memory access instruction caching|`ENABLED`|`n/a`|It presences permanently|
|OPTION_ICACHE_BLOCK_WIDTH|Specify the address width of a cache block|5|5, 4|see notes below|
|OPTION_ICACHE_SET_WIDTH|Specify the set address width|8|`n`|see notes below|
|OPTION_ICACHE_WAYS|Specify the number of blocks per set|2|`n`| |
|OPTION_ICACHE_LIMIT_WIDTH|Specify the maximum address width|32|`n`| |
|OPTION_ICACHE_CLEAR_ON_INIT|Clean up ICACHE RAM blocks at simulation start|0|0, 1|see notes below|

**Note 3:** *When `OPTION_I(D)CACHE_BLOCK_WIDTH` is 5, that means cache block is 32 bytes length, i.e.
8 of 32-bits words, i.e. bust length is 8. Analogue to that if `OPTION_I(D)CACHE_BLOCK_WIDTH` is 4,
cache block is 16 bytes length, i.e. 4 of 32-bits words, i.e. bust length is 4.
As Wishbone bridges are designed to support only 8/4 length bursts the only 5/4 values are suitable
for `OPTION_I(D)CACHE_BLOCK_WIDTH`.*

**Note 4:** *MAROCCHINO caches are virtually indexed and physically tagged. If you plan to use Linux
(or any other OS involving IMMUs for virtual addressing support) you must select such
`OPTION_I(D)CACHE_BLOCK_WIDTH` and `OPTION_I(D)CACHE_SET_WIDTH` to achieve
`OPTION_I(D)CACHE_BLOCK_WIDTH + OPTION_I(D)CACHE_SET_WIDTH = 13`. 13-bits is minimal page size for OpenRISC.
Recommended `OPTION_I(D)CACHE_BLOCK_WIDTH/OPTION_I(D)CACHE_SET_WIDTH` pairs are `5/8` and `4/9`.*

**Note 5:** *The `OPTION_I(D)CACHE_CLEAR_ON_INIT` could be used to force clean up all I(D)CACHE RAM block
at simulation start if something goes wrong during simulations. At the same time if you have to involve
such initialization that typically means that something wrong with your testing environment.*

### Memory Management Unit (MMU) parameters

|Parameter|Description|Default|Values|Comments|
|---------|-----------|-------|------|--------|
|FEATURE_DMMU|Enable the data bus MMU|`ENABLED`|`n/a`|It presences permanently|
|FEATURE_DMMU_HW_TLB_RELOAD|Enable hardware TLB reload|`NONE`|`n/a`|not implemented|
|OPTION_DMMU_SET_WIDTH|Specify the set address width|6|`n`| |
|OPTION_DMMU_WAYS|Specify the number of ways per set|1|`n`| |
|FEATURE_IMMU|Enable the instruction bus MMU|`ENABLED`|`n/a`|It presences permanently|
|FEATURE_IMMU_HW_TLB_RELOAD|Enable hardware TLB reload|`NONE`|`n/a`|not implemented|
|OPTION_IMMU_SET_WIDTH|Specify the set address width|6|`n`| |
|OPTION_IMMU_WAYS|Specify the number of ways per set|1|`n`| |

### System bus parameters

|Parameter|Description|Default|Values|Comments|
|---------|-----------|-------|------|--------|
|FEATURE_STORE_BUFFER|Enable store buffer|`ENABLED`|`n/a`|It presences permanently|
|OPTION_STORE_BUFFER_DEPTH_WIDTH|Specify num bits for store buffer depth width|4|1-n|16 taps by default|
|OPTION_STORE_BUFFER_CLEAR_ON_INIT|Clean up at simulation start|0|0, 1| |
|BUS_IF_TYPE|Specify the bus interface type|`WISHBONE32`|`n/a`|Other buses are not supported. Width is hard-coded.|
|IBUS_WB_TYPE|Specify the Instruction bus interface type option|`B3_READ_BURSTING`|`n/a`| |
|DBUS_WB_TYPE|Specify the Data bus interface type option|`B3_READ_BURSTING`|`n/a`| |

### Hardware unit configuration parameters

|Parameter|Description|Default|Values|Comments|
|---------|-----------|-------|------|--------|
|FEATURE_TRACEPORT_EXEC|Enable the traceport hardware interface|`NONE`|`ENABLED` `NONE`|Verilator|
|FEATURE_DEBUGUNIT|Enable hardware breakpoints and advanced debug unit interface|`NONE`|`ENABLED` `NONE`|OpenOCD|
|FEATURE_PERFCOUNTERS|Enable the performance counters unit|`NONE`|`n/a`|not implemented|
|OPTION_PERFCOUNTERS_NUM|Specify the number of performance counters to generate|0|`n/a`|not implemented|
|FEATURE_TIMER|Enable the internal OpenRISC timer|`ENABLED`|`n/a`|It presences permanently|
|FEATURE_PIC|Enable the internal OpenRISC PIC|`ENABLED`|`n/a`|It presences permanently|
|OPTION_PIC_TRIGGER|Specify the PIC trigger mode|`LEVEL`|`LEVEL` `EDGE` `LATCHED_LEVEL`| |
|OPTION_PIC_NMI_WIDTH|Specify non maskable interrupts width, starting at 0, these interrupts will not be reset or maskable|0|0-32| |
|OPTION_RF_CLEAR_ON_INIT|Enable clearing all registers on initialization|0|0, 1| |
|OPTION_RF_NUM_SHADOW_GPR|Specify the number of shadow register files|0|0-16|Set `>=1` for Linux SMP|
|OPTION_RF_ADDR_WIDTH|Specify the address width of the register file|5|5| |
|OPTION_RF_WORDS|Specify the number of registers in the register file|32|32| |
|FEATURE_FASTCONTEXTS|Enable fast context switching of register sets|`NONE`|`n/a`|not implemented|
|FEATURE_MULTICORE|Enable the `coreid` and `numcores` SPR registers|`NONE`|`ENABLED` `NONE`|Linux SMP|
|FEATURE_FPU|Enable the FPU|`ENABLED`|`n/a`|It presences permanently|
|OPTION_ORFPX64A32_ABI|ABI variant to support doubles on 32-bits architectures|`GCC5`|`GCC5` `GCC9`|till GCC9 release|
|OPTION_FTOI_ROUNDING|Select rounding behavior for `lf.ftoi.s(d)` instructions|`CPP`|`CPP` `IEEE`|see note below|
|FEATURE_BRANCH_PREDICTOR|Select the branch predictor implementation|`GSHARE`|`n/a`|It presences permanently|

**Note 6:** *C/C++ double to integer conversion assumes truncation (rounding `toward zero`).
The default (`CPP`) value of OPTION_FTOI_ROUNDING forces `toward zero` rounding mode exclusively for
`lf.ftoi.s(d)` instructions regardless of `rounding mode` bits of FPCSR. While with `IEEE` value
`lf.ftoi.s(d)` perform conversion in according with `rounding mode` bits of FPCSR. And these bits are
`nearest-even` rounding mode by default. All other floating point instructions always perform rounding
in according with `rounding mode` bits of FPCSR.*

### Exception handling options

|Parameter|Description|Default|Values|Comments|
|---------|-----------|-------|------|--------|
|FEATURE_DSX|Enable setting the `SR[DSX]` flag when raising exceptions in a delay slot|`ENABLED`|`n/a`|permanently|
|FEATURE_RANGE|Enable checking and raising range exceptions|`ENABLED`|`n/a`|implemented|
|FEATURE_OVERFLOW|Enable checking and raising overflow exceptions|`ENABLED`|`n/a`|implemented|

### ALU configuration options

|Parameter|Description|Default|Values|Comments|
|---------|-----------|-------|------|--------|
|FEATURE_MULTIPLIER|Specify the multiplier implementation|`PIPELINED`|`n/a`|It presences permanently|
|FEATURE_DIVIDER|Specify the divider implementation|`SERIAL`|`n/a`|It presences permanently|
|OPTION_SHIFTER|Specify the shifter implementation|`BARREL`|`n/a`|It presences permanently|
|FEATURE_CARRY_FLAG|Enable checking and setting the carry flag|`ENABLED`|`n/a`|It presences permanently|

### Instruction enabling options

|Parameter|Description|Default|Values|Comments|
|---------|-----------|-------|------|--------|
|FEATURE_MAC|Enable the `l.mac*` multiply accumulate instructions|`NONE`|`n/a`|not implemented|
|FEATURE_SYSCALL|Enable the `l.sys` OS syscall instruction|`ENABLED`|`n/a`|permanently|
|FEATURE_TRAP|Enable the `l.trap` instruction|`ENABLED`|`n/a`|GDB|
|FEATURE_ADDC|Enable the `l.addc` add with `carry` flag instruction|`ENABLED`|`n/a`|permanently|
|FEATURE_SRA|Enable the `l.sra` shirt right arithmetic instruction|`ENABLED`|`n/a`|permanently|
|FEATURE_ROR|Enable the `l.ror*` rotate right instructions|`ENABLED`|`n/a`|permanently|
|FEATURE_EXT|Enable the `l.ext*` sign extend instructions|`ENABLED`|`n/a`|permanently|
|FEATURE_CMOV|Enable the `l.cmov` conditional move instruction|`ENABLED`|`n/a`|permanently|
|FEATURE_FFL1|Enable the `l.f[fl]1` find first/last set bit instructions|`ENABLED`|`n/a`|Linux|
|FEATURE_ATOMIC|Enable the `l.lwa` and `l.swa` atomic instructions|`ENABLED`|`n/a`|Linux SMP|
|FEATURE_CUST1|Enable the `l.cust*` custom instruction|`NONE`|`n/a`|not implemented|
|FEATURE_CUST2|Enable the `l.cust*` custom instruction|`NONE`|`n/a`|not implemented|
|FEATURE_CUST3|Enable the `l.cust*` custom instruction|`NONE`|`n/a`|not implemented|
|FEATURE_CUST4|Enable the `l.cust*` custom instruction|`NONE`|`n/a`|not implemented|
|FEATURE_CUST5|Enable the `l.cust*` custom instruction|`NONE`|`n/a`|not implemented|
|FEATURE_CUST6|Enable the `l.cust*` custom instruction|`NONE`|`n/a`|not implemented|
|FEATURE_CUST7|Enable the `l.cust*` custom instruction|`NONE`|`n/a`|not implemented|
|FEATURE_CUST8|Enable the `l.cust*` custom instruction|`NONE`|`n/a`|reserved for internal use|
