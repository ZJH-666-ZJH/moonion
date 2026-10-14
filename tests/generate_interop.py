from pathlib import Path
import os
os.chdir(Path(__file__).resolve().parents[1])
import json
from amazon.ion import simpleion
texts=['null','null.bool','true','false','null.int','null.float','null.decimal','null.timestamp','null.symbol','null.string','null.clob','null.blob','null.list','null.sexp','null.struct','0','-1','127','128','255','256','-9223372036854775808','9223372036854775807','123456789012345678901234567890','-123456789012345678901234567890','1d0','200d0','-200d0','128d0','-128d0','0d-2','-0d-2','123.4500','1d64','1d-64','1d127','1d-127','1d128','1d-128','1e0','-0e0','1.25e0','nan','+inf','-inf','2026T','2026-10T','2026-10-14','2026-10-14T08:30Z','2026-10-14T08:30-00:00','2026-10-14T08:30:00.001Z','2026-10-14T08:30:00.0100Z','2026-10-14T08:30:00.000Z','2026-01-01T00:15:00+08:00','2024-03-01T00:00:00+01:00','2026-12-31T23:30:00-02:00','"hello"','"中文测试"','"\\u03bb\\U0001f600"',"'true'","'false'","'null'","'nan'","'$10'","'has space'",'catalog', 'ann::value','first::second::{foo:1,foo:2,bar: [home,kitchen]}','[]','{}','()','[1, true, null, {x:2}]','(+ 1 (* 2 3))','{{"\\xFF\\x00\\x80"}}','{{AP8=}}','{{}}','other::$ion_symbol_table::1', '"'+('x'*300)+'"','['+','.join(str(i) for i in range(130))+']', '{'+','.join('field%d:%d'%(i,i) for i in range(130))+'}', '{{"'+''.join('\\x%02x'%i for i in range(256))+'"}}']
texts += ['0.1e0', '1.2345678901234567e0', '1.7976931348623157e308', '5e-324', '2.2250738585072014e-308', '-1.2345678901234567e-200', "'''line one\nline two'''", "'''a''' /* joined */ '''b'''", "{{'''a\\xFF'''}}", '"a\\\nb"']
texts += ['inf', "''::1", "{'true':1}", "{'''field''':1}", "{{'''a''' '''b'''}}", '2026-10-14T08:30:00.1234567890123Z']
fixtures=[]
for text in texts:
 value=simpleion.loads(text)
 blob=simpleion.dumps(value,binary=True)
 fixtures.append({'text':text,'hex':blob.hex()})
Path('tests').mkdir(exist_ok=True)
Path('tests/interop-fixtures.json').write_text(json.dumps(fixtures,ensure_ascii=False,indent=2)+'\n',encoding='utf8')
def q(s):return json.dumps(s,ensure_ascii=False)
blocks=[]
for i, f in enumerate(fixtures):
 blocks.append('''///|
test "official ion-python fixture %d" {
  let data = match hex_decode(%s) { Ok(v) => v; Err(e) => fail(e.message()) }
  let decoded = match load_binary(data) { Ok(v) => v; Err(e) => fail(e.message()) }
  let parsed = match load_text(%s) { Ok(v) => v; Err(e) => fail(e.message()) }
  assert_eq(dumps_text(decoded), dumps_text(parsed))
}
'''%(i,q(f['hex']),q(f['text'])))
Path('interop_wbtest.mbt').write_text('\n'.join(blocks),encoding='utf8')
Path('examples/interop').mkdir(exist_ok=True)
Path('examples/interop/moon.pkg').write_text('import { "ZJH-666-ZJH/moonion" @ion, }\npkgtype(kind: "executable")\n')
source='''///|
fn main {
'''
for i,f in enumerate(fixtures):
 source+='''  match @ion.load_text(%s) {
    Ok(v) => println(%s + "|" + @ion.hex_encode(@ion.dumps_binary(v)) + "|" + @ion.dumps_text(v))
    Err(e) => println(%s + "|ERROR|" + e.message())
  }
'''%(q(f['text']),q(str(i)),q(str(i)))
source+='''  let v = @ion.catalog_sample()
  println("catalog_sample|" + @ion.hex_encode(@ion.dumps_binary(v)) + "|" + @ion.dumps_text(v))
  let expr = @ion.sexp_sample()
  println("sexp_sample|" + @ion.hex_encode(@ion.dumps_binary(expr)) + "|" + @ion.dumps_text(expr))
}
'''
source = source.rstrip()[:-1] + '  let catalog : Array[@ion.SharedSymbolTable] = [{ name: "shared", version: 1, symbols: [Some("a"), None, Some("b")] }]\n  match @ion.hex_decode("e00100eaee9f8183de9b86be90de8e848673686172656485210188210387b6856c6f63616cde868a710c8d2101") {\n    Ok(data) => match @ion.load_bytes(data, catalog~) {\n      Ok(v) => println("shared_catalog|" + @ion.hex_encode(@ion.dumps_bytes(v)) + "|" + @ion.dumps(v))\n      Err(e) => println("shared_catalog|ERROR|" + e.message())\n    }\n    Err(e) => println("shared_catalog|ERROR|" + e.message())\n  }\n}\n'
Path('examples/interop/main.mbt').write_text(source,encoding='utf8')
print('fixtures:',len(fixtures))
