import re
import os

files = [
    r"docs\implementation_plan.md",
    r".planning\gsd_phase_roadmap.md"
]

def add_status_column(content):
    lines = content.split('\n')
    out = []
    in_table = False
    
    for line in lines:
        if line.startswith('| Task | Atomic Action'):
            out.append('| Status | Task | Atomic Action | Output |')
            in_table = True
        elif line.startswith('|------|'):
            out.append('|---|---|---|---|')
        elif in_table and line.startswith('| '):
            # Check if it's a task row (e.g. '| 0.1 |')
            parts = line.split('|')
            if len(parts) >= 3:
                task_num = parts[1].strip()
                if re.match(r'^\d+\.\d+$', task_num):
                    # It's a task. Phase 0 tasks are done.
                    if task_num.startswith('0.'):
                        out.append(f"| [x] | {task_num} |{'|'.join(parts[2:])}")
                    else:
                        out.append(f"| [ ] | {task_num} |{'|'.join(parts[2:])}")
                else:
                    # e.g., "| | **Landing Page..."
                    out.append(f"| | {task_num} |{'|'.join(parts[2:])}")
            else:
                out.append(line)
        elif line.startswith('|'):
            # Some other table row?
            out.append(line)
        else:
            in_table = False
            out.append(line)
            
    return '\n'.join(out)

for fpath in files:
    try:
        with open(fpath, 'r', encoding='utf-8') as f:
            content = f.read()
            
        new_content = add_status_column(content)
        
        with open(fpath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated {fpath}")
    except Exception as e:
        print(f"Error on {fpath}: {e}")
