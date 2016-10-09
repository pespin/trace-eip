all: build trace resolve

resolve:
	./resolvepc.sh ./infinite dump.*/task-*-*-infinite

trace: infinite
	# Makefile creates 1 shell per line. We need group them in same line otherwise
	# we cannot share vars.
	./infinite & \
	PID_INF=$$!; \
	echo "PID_INF $$PID_INF"; \
	timeout --preserve-status -s INT 5s ./tracepc.sh $$PID_INF; \
	kill -KILL $$PID_INF; \
	wait $$PID_INF || true;


build: infinite.c
	gcc -g -o infinite infinite.c


clean:
	rm -rf infinite dump.*
