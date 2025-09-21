#!/usr/bin/env bun
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import yaml from "js-yaml";

function runCmd(cmd, timeoutSec = null) {
	// cmd: string
	const parts = cmd.match(/(?:["'].*?["']|[^\s]+)/g) || [];
	const proc = spawnSync(parts[0], parts.slice(1), {
		encoding: "utf8",
		timeout: timeoutSec ? timeoutSec * 1000 : undefined,
	});
	if (proc.error) throw proc.error;
	if (proc.status !== 0) {
		const err = new Error(
			`Command failed: ${cmd} \nstdout:\n${proc.stdout}\nstderr:\n${proc.stderr}`,
		);
		err.stdout = proc.stdout;
		err.stderr = proc.stderr;
		throw err;
	}
	return proc;
}

function now() {
	return Number(process.hrtime.bigint()) / 1e9;
}

function ensureDir(p) {
	if (!fs.existsSync(p)) fs.mkdirSync(p, { recursive: true });
}

function escapeHtml(s) {
	return String(s)
		.replace(/&/g, "&amp;")
		.replace(/</g, "&lt;")
		.replace(/>/g, "&gt;");
}

function generateSVG(data) {
	// data: array of { task, language, mean_s }
	const tasks = [...new Set(data.map((d) => d.task))];
	const rowsPerTask = tasks.map((t) =>
		data.filter((d) => d.task === t).sort((a, b) => a.mean_s - b.mean_s),
	);

	const width = 1000;
	const perRowH = 32;
	const headerH = 60;
	const taskSpacing = 40;
	const margin = 20;
	const extraBottomPadding = 60; // Increased padding for bottom
	const height =
		headerH +
		rowsPerTask.reduce(
			(s, arr) => s + arr.length * perRowH + taskSpacing,
			0,
		) +
		margin * 2 + extraBottomPadding + taskSpacing; // Added extra taskSpacing for final task

	// find global max to scale bars, but cap extreme outliers
	const maxVal = Math.max(...data.map((d) => d.mean_s));
	const leftPad = 180;
	const barMaxWidth = width - leftPad - 120;
	
	// Cap bar width for extreme outliers to prevent overflow
	const maxReasonableBarWidth = barMaxWidth * 0.9; // Use 90% of available space

	// Color palette for different performance tiers
	const getBarColor = (rank, total) => {
		const ratio = rank / (total - 1);
		if (ratio < 0.3) return "#22c55e"; // Green for fastest
		if (ratio < 0.6) return "#3b82f6"; // Blue for medium
		if (ratio < 0.8) return "#f59e0b"; // Orange for slower
		return "#ef4444"; // Red for slowest
	};

	let y = margin + 25;
	let svg = `<?xml version="1.0" encoding="utf-8"?>\n<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}">\n`;

	// White background
	svg += `<rect width="100%" height="100%" fill="white"/>\n`;

	// Enhanced styles
	svg += `<style>
    text { font-family: 'Segoe UI', Arial, sans-serif; font-size: 13px; }
    .title { font-size: 18px; font-weight: 600; fill: #1f2937; }
    .task-header { font-size: 15px; font-weight: 600; fill: #374151; }
    .lang-label { font-size: 12px; fill: #4b5563; }
    .time-label { font-size: 11px; fill: #6b7280; font-weight: 500; }
    .bar { rx: 3; ry: 3; }
    .divider { stroke: #e5e7eb; stroke-width: 1; }
  </style>\n`;

	svg += `<text x="${margin}" y="30" class="title">Multi-Language Benchmark Results</text>\n`;
	svg += `<text x="${margin}" y="50" style="font-size:12px;fill:#6b7280;">Performance comparison (fastest → slowest within each task)</text>\n`;
	y += 25;

	for (let taskIdx = 0; taskIdx < tasks.length; taskIdx++) {
		const task = tasks[taskIdx];
		const rows =
			rowsPerTask[taskIdx] ||
			data.filter((d) => d.task === task).sort((a, b) => a.mean_s - b.mean_s);

		// Task divider line (except for first task)
		if (taskIdx > 0) {
			svg += `<line x1="${margin}" y1="${y - 10}" x2="${width - margin}" y2="${y - 10}" class="divider"/>\n`;
		}

		svg += `<text x="${margin}" y="${y + 18}" class="task-header">${escapeHtml(task)}</text>\n`;

		for (let i = 0; i < rows.length; i++) {
			const r = rows[i];
			const rawBarW = Math.round((r.mean_s / maxVal) * barMaxWidth);
			const barW = Math.max(4, Math.min(rawBarW, maxReasonableBarWidth));
			const yy = y + 35 + i * perRowH;
			const color = getBarColor(i, rows.length);

			// Language label
			svg += `<text x="${margin}" y="${yy + 18}" class="lang-label">${escapeHtml(r.language)}</text>`;

			// Performance bar with gradient effect
			svg += `<rect x="${leftPad}" y="${yy + 4}" width="${barW}" height="20" fill="${color}" class="bar" opacity="0.8"/>`;
			svg += `<rect x="${leftPad}" y="${yy + 4}" width="${barW}" height="6" fill="${color}" class="bar"/>`;

			// Time label - position it properly even for capped bars
			const labelX = Math.min(leftPad + barW + 8, width - 80);
			svg += `<text x="${labelX}" y="${yy + 18}" class="time-label">${r.mean_s.toFixed(3)}s</text>\n`;
		}
		y +=
			35 +
			rows.length * perRowH +
			(taskIdx < tasks.length - 1 ? taskSpacing : 0);
	}

	svg += "</svg>";
	return svg;
}

async function main() {
	// Check for --svg-only flag
	const svgOnlyMode = process.argv.includes("--svg-only");
	
	if (svgOnlyMode) {
		// Generate SVG from existing results/summary.json
		if (!fs.existsSync("results/summary.json")) {
			console.error("Error: results/summary.json not found. Run benchmark first without --svg-only flag.");
			process.exit(1);
		}
		
		const allResults = JSON.parse(fs.readFileSync("results/summary.json", "utf8"));
		console.log("Generating SVG from existing results...");
		
		try {
			const svg = generateSVG(allResults);
			fs.writeFileSync("results/summary.svg", svg, "utf8");
			console.log("SVG generated: results/summary.svg");
		} catch (e) {
			console.error("Failed to generate SVG:", (e && e.message) || e);
			process.exit(1);
		}
		return;
	}

	const cfgPath = process.argv[2] || "harness/config.yaml";
	const cfg = yaml.load(fs.readFileSync(cfgPath, "utf8"));
	const globalsCtx = cfg.globals || {};
	const tasks = cfg.tasks || [];
	const runs = cfg.runs || {};
	const languages = cfg.languages || [];
	const warmup = Number(runs.warmup || 1);
	const repeat = Number(runs.repeat || 5);
	const timeout = runs.timeout_sec ? Number(runs.timeout_sec) : null;

	ensureDir("results");

	// Build step
	for (const lang of languages) {
		const buildCmd = (lang.build || "").trim();
		if (buildCmd) {
			console.log(`[BUILD] ${lang.id}: ${buildCmd}`);
			try {
				runCmd(buildCmd, 1200);
			} catch (e) {
				console.error(`Build failed for ${lang.id}:`, e.stderr || e.message);
				process.exit(1);
			}
		}
	}

	const allResults = [];

	for (const task of tasks) {
		const tname = task.name;
		const argsTpl = task.args || "";
		const argstr = argsTpl.replace(/\{(\w+)\}/g, (_m, k) => globalsCtx[k]);
		console.log(`\n=== Task: ${tname} args=[${argstr}] ===`);

		for (const lang of languages) {
			const runTpl = lang.run;
			const cmdStr = runTpl.replace("{task}", tname).replace("{args}", argstr);
			const times = [];
			console.log(`[RUN] ${lang.id}: ${cmdStr}`);

			// Warmup
			for (let i = 0; i < warmup; i++) {
				try {
					if (timeout) runCmd(cmdStr, timeout);
					else runCmd(cmdStr);
					console.log(`  warmup ${i + 1}/${warmup} ok`);
				} catch (e) {
					console.error(
						`Warmup failed ${tname} for ${lang.id}:`,
						e.stderr || e.message,
					);
					process.exit(1);
				}
			}

			for (let i = 0; i < repeat; i++) {
				try {
					const t0 = now();
					if (timeout) runCmd(cmdStr, timeout);
					else runCmd(cmdStr);
					const t1 = now();
					const elapsed = t1 - t0;
					times.push(elapsed);
					console.log(`  run ${i + 1}/${repeat}: ${elapsed.toFixed(6)}s`);
				} catch (e) {
					console.error(
						`Run failed ${tname} for ${lang.id}:`,
						e.stderr || e.message,
					);
					process.exit(1);
				}
			}

			const mean = times.reduce((a, b) => a + b, 0) / times.length;
			const sorted = [...times].sort((a, b) => a - b);
			const median =
				sorted.length % 2
					? sorted[(sorted.length - 1) / 2]
					: (sorted[sorted.length / 2 - 1] + sorted[sorted.length / 2]) / 2;
			const stdev = Math.sqrt(
				times.map((x) => Math.pow(x - mean, 2)).reduce((a, b) => a + b, 0) /
					times.length,
			);

			allResults.push({
				task: tname,
				args: argstr,
				language: lang.id,
				runs: repeat,
				warmup: warmup,
				mean_s: mean,
				median_s: median,
				stdev_s: stdev,
				min_s: Math.min(...times),
				max_s: Math.max(...times),
				raw_s: times,
			});
		}

		// Per-task summary
		console.log(`\n--- Summary for task: ${tname} ---`);
		console.log(
			`${"language".padEnd(10)} ${"mean".padStart(10)} ${"median".padStart(10)} ${"stdev".padStart(10)} ${"min".padStart(10)} ${"max".padStart(10)}`,
		);
		const perTask = allResults
			.filter((r) => r.task === tname)
			.sort((a, b) => a.mean_s - b.mean_s);
		for (const r of perTask) {
			console.log(
				`${r.language.padEnd(10)} ${r.mean_s.toFixed(6).padStart(10)} ${r.median_s.toFixed(6).padStart(10)} ${r.stdev_s.toFixed(6).padStart(10)} ${r.min_s.toFixed(6).padStart(10)} ${r.max_s.toFixed(6).padStart(10)}`,
			);
		}
	}

	fs.writeFileSync("results/summary.json", JSON.stringify(allResults, null, 2));
	// CSV
	const csvLines = [
		"task,args,language,runs,warmup,mean_s,median_s,stdev_s,min_s,max_s",
	];
	for (const r of allResults)
		csvLines.push(
			[
				r.task,
				r.args,
				r.language,
				r.runs,
				r.warmup,
				r.mean_s,
				r.median_s,
				r.stdev_s,
				r.min_s,
				r.max_s,
			].join(","),
		);
	fs.writeFileSync("results/summary.csv", csvLines.join("\n"));
	
	try {
		const svg = generateSVG(allResults);
		fs.writeFileSync("results/summary.svg", svg, "utf8");
		console.log(
			"\nWrote results/summary.json, results/summary.csv and results/summary.svg",
		);
	} catch (e) {
		console.error("Failed to generate SVG:", (e && e.message) || e);
		console.log("\nWrote results/summary.json and results/summary.csv");
	}
}

main();
