import os

target_dir = 'lib'
keywords = ['read', 'shloka']

for root, dirs, files in os.walk(target_dir):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            try:
                with open(path, 'r', encoding='utf-8') as f:
                    lines = f.readlines()
                for idx, line in enumerate(lines):
                    line_lower = line.lower()
                    if any(kw in line_lower for kw in keywords):
                        # Filter for interesting layout elements
                        line_strip = line.strip()
                        if any(term in line_strip for term in ['Text', 'Icon', 'Container', 'Row', 'Column', 'Box', 'widget', 'title', 'category', 'label']):
                            print(f"{os.path.relpath(path, target_dir)}:{idx+1}: {line_strip}")
            except Exception as e:
                pass
