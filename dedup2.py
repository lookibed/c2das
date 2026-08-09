"""Dedup structs (any indent), fix .type_N refs."""
import re
path = "/mnt/d/Backups/Spider/tests/manual/real-world-h264bsd-mp4/src/all.das"
with open(path) as f:
    lines = f.readlines()
seen = set()
out = []
i = 0
while i < len(lines):
    line = lines[i]
    m = re.match(r'^\s*(struct|enum)\s+(\w+)\s*\{', line)
    if m:
        name = m.group(2)
        if name in seen:
            depth = 1
            i += 1
            while i < len(lines) and depth > 0:
                depth += lines[i].count('{') - lines[i].count('}')
                if depth <= 0:
                    j = lines[i].rfind('}')
                    if j >= 0:
                        after = lines[i][j+1:]
                        if after.strip():
                            out.append(after)
                    break
                i += 1
            i += 1
            continue
        seen.add(name)
    out.append(line)
    i += 1
text = ''.join(out)
for m in re.finditer(r'^typedef\s+(\w+)\s*=\s*(\S+)', text, re.M):
    text = text.replace(f".type_{m.group(1)}", m.group(1))
for m in re.finditer(r'^struct\s+(\w+)', text, re.M):
    text = text.replace(f".type_{m.group(1)}", m.group(1))
for m in re.finditer(r'^enum\s+(\w+)', text, re.M):
    text = text.replace(f".type_{m.group(1)}", m.group(1))
with open(path, 'w') as f:
    f.write(text)
print(f"{len(lines)}->{len(out)} lines, {len(seen)} structs")
