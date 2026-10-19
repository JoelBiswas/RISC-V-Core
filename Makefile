# Forward verification commands to the simulation directory.
# Command-line variables are inherited, e.g. make xrun SEED=42.
VERIFICATION_DIR := Verification/sim/behav
VERIFICATION_TARGETS := help clean link xrun simvision coverage run_and_view

.DEFAULT_GOAL := help
.PHONY: $(VERIFICATION_TARGETS)

$(VERIFICATION_TARGETS):
	+$(MAKE) -C "$(VERIFICATION_DIR)" $@
