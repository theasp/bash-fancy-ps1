TARGETS=fancy-ps1.bash

all: deps $(TARGETS)

clean:
	$(RM) $(TARGETS)

fancy-ps1.bash: src/fancy-ps1.bash deps/bash-preexec/bash-preexec.sh
	cat $^ > $@
	chmod +x fancy-ps1.bash

deps: deps/bash-preexec/bash-preexec.sh

deps/bash-preexec/bash-preexec.sh: deps/bash-preexec
	git submodule update --init deps/bash-preexec

.PHONY: all deps clean
