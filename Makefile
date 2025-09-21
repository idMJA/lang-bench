.PHONY: build bench clean

build:
	@echo "==> Building languages"
	@bash -lc "if [ -f languages/c/build.sh ]; then bash languages/c/build.sh; fi"
	@bash -lc "if [ -f languages/cpp/build.sh ]; then bash languages/cpp/build.sh; fi"
	@bash -lc "if [ -f languages/rust/build.sh ]; then bash languages/rust/build.sh; fi"
	@bash -lc "if [ -f languages/go/build.sh ]; then bash languages/go/build.sh; fi"
	@bash -lc "if [ -f languages/java/build.sh ]; then bash languages/java/build.sh; fi"
	@bash -lc "if [ -f languages/kotlin/build.sh ]; then bash languages/kotlin/build.sh; fi"
	@bash -lc "if [ -f languages/csharp/build.sh ]; then bash languages/csharp/build.sh; fi"
	@bash -lc "if [ -f languages/swift/build.sh ]; then bash languages/swift/build.sh; fi"
	@bash -lc "if [ -f languages/d/build.sh ]; then bash languages/d/build.sh; fi"
	@bash -lc "if [ -f languages/nim/build.sh ]; then bash languages/nim/build.sh; fi"
	@bash -lc "if [ -f languages/pypy/build.sh ]; then bash languages/pypy/build.sh; fi"
	@bash -lc "if [ -f languages/deno/build.sh ]; then bash languages/deno/build.sh; fi"
	@bash -lc "if [ -f languages/elixir/build.sh ]; then bash languages/elixir/build.sh; fi"
	@bash -lc "if [ -f languages/lua/build.sh ]; then bash languages/lua/build.sh; fi"
	@bash -lc "if [ -f languages/julia/build.sh ]; then bash languages/julia/build.sh; fi"
	@echo "Build complete."

bench:
	@echo "==> Running benchmark"
	@bun harness/run_bench.js harness/config.yaml

clean:
	@rm -rf \
		languages/c/multi languages/cpp/multi languages/go/multi languages/rust/multi \
		languages/java/out languages/kotlin/Multi.jar languages/csharp/out languages/swift/multi \
		languages/d/multi languages/d/*.o languages/nim/multi languages/elixir/*.beam
	@find languages -name "__pycache__" -type d -exec rm -rf {} +
	@echo "Clean complete."