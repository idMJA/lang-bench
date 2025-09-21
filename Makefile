.PHONY: build bench clean

build:
	@echo "==> Building languages"
	@for f in languages/*/build.sh; do \
		if [ -f "$$f" ]; then bash "$$f"; fi; \
	done
	@echo "Build complete."

bench:
	@echo "==> Running benchmark"
	@bun harness/run_bench.js harness/config.yaml

clean:
	@rm -rf languages/*/multi languages/java/out languages/kotlin/Multi.jar languages/csharp/out languages/d/*.o languages/elixir/_build
	@find languages -name "__pycache__" -type d -exec rm -rf {} +
	@echo "Clean complete."