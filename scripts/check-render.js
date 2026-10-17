// Check the chat markdown renderer extracted from web/index.html.
const fs = require('fs');
const html = fs.readFileSync(__dirname + '/../web/index.html', 'utf8');
const script = html.slice(html.indexOf('<script>') + 8, html.lastIndexOf('</script>'));
new Function(script); // syntax check of the whole inline script

const start = html.indexOf('function esc(');
const end = html.indexOf('function add(');
if (start < 0 || end < 0) throw new Error('renderer not found in web/index.html');
const stubDoc = { addEventListener() {}, createElement: t => new (class { constructor() { this.tag = t; } })() };
const mdRender = new Function('document', html.slice(start, end) + '; return mdRender;')(stubDoc);

const cases = [
  ['heading', '# Title\nbody', m => m.includes('<h3>Title</h3>')],
  ['bold', 'a **b** c', m => m.includes('<strong>b</strong>')],
  ['italic guard', '5 * 3 * 2', m => !m.includes('<em>')],
  ['fence', 'x\n```python\nprint("**not bold**")\n```', m => m.includes('<pre class="code">') && m.includes('print("**not bold**")') && !m.includes('```')],
  ['inline code kept', 'use `a*b*c` ok', m => m.includes('<code>a*b*c</code>')],
  ['inline code not double escaped', 'run `<a>` now', m => m.includes('<code>&lt;a&gt;</code>')],
  ['list grouped', '- one\n- two', m => m.match(/<ul>/g).length === 1 && m.includes('<li>two</li>')],
  ['xss escaped', '<script>alert(1)</script>', m => !m.includes('<script>') && m.includes('&lt;script&gt;')],
  ['js link not turned into href', '[x](javascript:alert(1))', m => !m.includes('href="javascript')],
  ['http link kept', '[docs](https://example.com/a)', m => m.includes('href="https://example.com/a"')],
  ['newline preserved', 'a\nb', m => m.includes('a\nb')],
  ['table rendered', '| A | B |\n|---|---|\n| 1 | 2 |', m => m.includes('<table>') && m.includes('<th>A</th>') && m.includes('<td>2</td>') && !m.includes('<td>---</td>')],
  ['table keeps other rows', 'x\n| A |', m => !m.includes('<table>')],
  ['table escapes cells', '| a |\n|---|\n| <b> |', m => m.includes('<td>&lt;b&gt;</td>')],
  ['thematic break', 'a\n---\nb', m => m.includes('<hr>') && !m.includes('\n---\n')],
  ['rule not confused with table', '| a | b |\n|---|---|\n| 1 | 2 |', m => m.includes('<table>') && !m.includes('<hr>')],
  ['code block gets copy button', '```py\nx=1\n```', m => m.includes('class="codeblock"') && m.includes('data-kind="code"')],
  ['copy handler registered', '', () => html.includes("closest('.copy-btn')") && html.includes('navigator.clipboard.writeText')],
  ['tool head can shrink', '', () => html.includes('.msg.tool .tool-head{min-width:0}')],
  ['copy sits at end of message', '', () => html.includes('.msg .copy-btn{position:static;display:block') && html.includes('.codeblock .copy-btn{position:absolute')],
  ['bubbles never shrink vertically', '', () => html.includes('.msg{overflow:hidden;flex-shrink:0}')],
];

let bad = 0;
for (const [name, input, ok] of cases) {
  const out = mdRender(input);
  const pass = ok(out);
  if (!pass) { bad++; console.log('FAIL ' + name + ' -> ' + out); }
}
console.log(bad ? bad + ' failed' : 'all ' + cases.length + ' checks passed');

// Tool bubbles start collapsed and expand on click.
class El {
  constructor(tag) { this.tag = tag; this.children = []; this.attrs = {}; this._cls = new Set(); this.textContent = ''; this.onclick = null; }
  set className(v) { this._cls = new Set(String(v).split(/\s+/).filter(Boolean)); }
  get className() { return [...this._cls].join(' '); }
  get classList() { const s = this._cls; return {
    toggle: c => { if (s.has(c)) { s.delete(c); return false; } s.add(c); return true; },
    contains: c => s.has(c) }; }
  setAttribute(k, v) { this.attrs[k] = v; }
  append(...n) { this.children.push(...n); }
  querySelector(sel) { const cls = sel.slice(1);
    const walk = e => { for (const c of e.children) { if (c._cls.has(cls)) return c; const r = walk(c); if (r) return r; } return null; };
    return walk(this); }
}
const tools = new Function('document', html.slice(html.indexOf('function toolUpdate('), html.indexOf('function add(')) + '; return {toolUpdate,toolBox};')({ createElement: t => new El(t), addEventListener() {} });
const box = new El('div');
tools.toolBox(box); tools.toolUpdate(box, 'RESULT · read_file\nline1\nline2');
const btn = box.querySelector('.tool-toggle'), head = box.querySelector('.tool-head'), body = box.querySelector('.tool-body');
const toolCases = [
  ['head is first line', head.textContent === 'RESULT · read_file'],
  ['body keeps full text', body.textContent.includes('line2')],
  ['starts collapsed', body.classList.contains('hidden') && btn.attrs['aria-expanded'] === 'false'],
];
btn.onclick();
toolCases.push(['expands on click', !body.classList.contains('hidden') && btn.attrs['aria-expanded'] === 'true']);
btn.onclick();
toolCases.push(['collapses again', body.classList.contains('hidden') && btn.attrs['aria-expanded'] === 'false']);
let badTools = 0;
for (const [name, ok] of toolCases) if (!ok) { badTools++; console.log('FAIL ' + name); }
console.log(badTools ? badTools + ' tool checks failed' : 'all ' + toolCases.length + ' tool checks passed');
process.exit(bad || badTools ? 1 : 0);
