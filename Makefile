TOP ?= tb_uart
TC ?= uart_base_test
SEED ?= 12345
FSDB ?= novas.fsdb

VCS_OPTS := -full64 -sverilog
VCS_OPTS += -ntb_opts uvm-1.2
VCS_OPTS += -timescale=1ns/1ps
VCS_OPTS += -debug_access+all -kdb -lca
VCS_OPTS += +incdir+./tb

SIM_OPTS := +UVM_TESTNAME=$(TC)
SIM_OPTS += +UVM_VERBOSITY=UVM_LOW
SIM_OPTS += +ntb_random_seed=$(SEED)

VERDI_OPTS := -sv -f filelist.f -dbdir simv.daidir -ssf $(FSDB)

CLEAN_ARTIFACTS := simv simv.daidir csrc ucli.key DVEfiles *.key *.h *.log
DISTCLEAN_ARTIFACTS := AN.DB verdiLog vdCovLog coverage.vdb vdCov.conf \
	$(FSDB) $(FSDB).* $(FSDB)* novas.conf novas.rc inter.fsdb inter.fsdb.* \
	.inter.fsdb.tbsim .vcs_checkpoint_shared_memory.* sysProgressP.conf sysProgressPLog

.PHONY: compile sim verdi clean distclean clear sim_base sim_tx sim_rx sim_loopback

compile:
	vcs $(VCS_OPTS) -top $(TOP) -o simv -f filelist.f

sim: compile
	rm -rf $(FSDB) $(FSDB).* $(FSDB)*
	./simv $(SIM_OPTS)

verdi:
	verdi $(VERDI_OPTS)

sim_base:
	$(MAKE) sim TC=uart_base_test

sim_tx:
	$(MAKE) sim TC=uart_tx_test

sim_rx:
	$(MAKE) sim TC=uart_rx_test

sim_loopback:
	$(MAKE) sim TC=uart_loopback_test

clean:
	rm -rf $(CLEAN_ARTIFACTS)

distclean: clean
	rm -rf $(DISTCLEAN_ARTIFACTS)

clear: distclean
