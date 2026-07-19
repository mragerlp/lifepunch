import pathlib
s = pathlib.Path(r'C:\Users\jared\Projects\lifepunch\.tmp-cvlbrand\index.html').read_text(encoding='utf-8')
a1 = '            <a class="btn btn-secondary" href="/system/">See how it works</a>\n          </div>\n        </div>'
print('anchor count:', s.count(a1))
i = s.index('See how it works')
print(repr(s[i-60:i+120]))
