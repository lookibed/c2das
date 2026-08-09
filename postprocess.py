"""Postprocess all.das: dedup structs (line-by-line brace tracking), fix .type_N refs."""
import re

path = "/mnt/d/Backups/Spider/tests/manual/real-world-h264bsd-mp4/src/all.das"
with open(path) as f:
    lines = f.readlines()

# Phase 1: Dedup structs via line-by-line brace-depth parsing
seen_structs = set()
out = []
i = 0
while i < len(lines):
    line = lines[i]
    m = re.match(r'^(struct|enum)\s+(\w+)\s*\{', line)
    if m:
        kind, name = m.group(1), m.group(2)
        if name in seen_structs:
            # consume entire block
            depth = 1
            i += 1
            while i < len(lines) and depth > 0:
                depth += lines[i].count('{')
                depth -= lines[i].count('}')
                i += 1
            continue
        seen_structs.add(name)
    out.append(line)
    i += 1

text = ''.join(out)

# Phase 2: Fix .type_N references
for m in re.finditer(r'^typedef\s+(\w+)\s*=\s*(\S+)', text, re.M):
    text = text.replace(f".type_{m.group(1)}", m.group(1))
for m in re.finditer(r'^struct\s+(\w+)', text, re.M):
    text = text.replace(f".type_{m.group(1)}", m.group(1))
for m in re.finditer(r'^enum\s+(\w+)', text, re.M):
    text = text.replace(f".type_{m.group(1)}", m.group(1))

with open(path, 'w') as f:
    f.write(text)
print(f"Postprocessed {path}: {len(lines)} -> {len(out)} lines, {len(seen_structs)} structs kept")
