#!/usr/bin/env python3
"""Serve Flutter and proxy API calls on localhost only."""
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
from pathlib import Path
import os, urllib.request, urllib.error
ROOT=Path(__file__).resolve().parents[1]/'wallet_mobile/build/web'
class Handler(SimpleHTTPRequestHandler):
 def __init__(self,*args,**kwargs): super().__init__(*args,directory=str(ROOT),**kwargs)
 def proxy(self):
  target=None
  for prefix,base in [('/wallet/','http://127.0.0.1:8091/'),('/services/','http://127.0.0.1:8092/')]:
   if self.path.startswith(prefix): target=base+self.path[len(prefix):]; break
  if target is None: return False
  data=self.rfile.read(int(self.headers.get('Content-Length',0))) if self.command=='POST' else None
  headers={k:v for k,v in self.headers.items() if k.lower() in ('authorization','content-type','accept')}
  request=urllib.request.Request(target,data=data,headers=headers,method=self.command)
  try: response=urllib.request.urlopen(request,timeout=25)
  except urllib.error.HTTPError as e: response=e
  except urllib.error.URLError:
   self.send_error(502,'Backend indisponible'); return True
  with response:
   body=response.read(); self.send_response(response.code)
   self.send_header('Content-Type',response.headers.get('Content-Type','application/json'))
   self.send_header('Content-Length',str(len(body))); self.end_headers(); self.wfile.write(body)
  return True
 def do_GET(self):
  if not self.proxy(): super().do_GET()
 def do_POST(self):
  if not self.proxy(): self.send_error(404)
if __name__=='__main__':
 if not (ROOT/'index.html').exists(): raise SystemExit('Exécutez d’abord : cd wallet_mobile && flutter build web --release')
 port=int(os.environ.get('PORT','8080'))
 print(f'Sama Wallet : http://localhost:{port}',flush=True)
 ThreadingHTTPServer(('127.0.0.1',port),Handler).serve_forever()
