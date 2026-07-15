#!/bin/bash
set -euo pipefail

exec vllm serve google/gemma-4-12B-it-qat-w4a16-ct \
	--max-model-len 262144 \
	--gpu-memory-utilization 0.90 \
	--tool-call-parser gemma4 \
	--enable-auto-tool-choice
